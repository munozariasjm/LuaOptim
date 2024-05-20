#Imports for M-LOOP
import mloop.interfaces as mli
import mloop.controllers as mlc
import mloop.visualizations as mlv
from datetime import date
from time import gmtime, strftime

#Other imports
import numpy as np
import time
import matplotlib.pyplot as plt

import subprocess
import os


#Declare your custom class that inherits from the Interface class
class CustomInterface(mli.Interface):

    #Initialization of the interface, including this method is optional
    def __init__(self):
        #You must include the super command to call the parent class, Interface, constructor
        super(CustomInterface,self).__init__()

    #You must include the get_next_cost_dict method in your class
    #this method is called whenever M-LOOP wants to run an experiment
    def get_next_cost_dict(self,params_dict):

        #Get parameters from the provided dictionary
        params = params_dict['params']
        V1 = params[0]
        V2 = params[1]
        V3 = params[2]
        V4 = params[3]
        V5 = params[4]

        filename = "out_test.txt"

        try:
            os.remove(filename)
        except:
            print("")

        # Call SIMION from terminal
        subprocess.call(r"powershell.exe & '.\SIMION 8.1.lnk' --nogui fastadj C:\Users\PRECIOSA_01\Desktop\SIMION\VMI_optimize\VMI_3.PA0 " + "1=" + str(V1) + ",2=" + str(V2) + ",3=" + str(V3) + ",4=" + str(V4) + ",5=" + str(V5))
        subprocess.call(r"powershell.exe & '.\SIMION 8.1.lnk' --nogui fly --restore-potentials=0 --recording-output=out_test.txt C:\Users\PRECIOSA_01\Desktop\SIMION\VMI_optimize\geom3.iob")

        # This is needed to make sure everything from SIMION is written to file before the python script continues
        total_time = 0
        while True:
            if os.path.isfile(".\out_test.txt"):
                data = np.loadtxt(filename,skiprows=1,usecols=0)
                if len(data)==1000:
                    ok = 1
                    break
                else:
                    time.sleep(0.2)
            elif total_time<10:
                time.sleep(0.2)
                total_time = total_time + 0.2
            else:
                ok = 0
                break

        # Process the data from SIMION and build your cost function for the NN optimization
        if ok==1:
            data_simion = np.loadtxt(filename,skiprows=1)
            idx = np.where(data_simion[:,0]==50)
            data_simion = data_simion[idx]
            pos_y = data_simion[:,1]
            pos_z = data_simion[:,2]
            radius = np.sqrt((pos_y)**2+(pos_z)**2)
            if len(data_simion)<900:
                resolution = 1000
            else:
                resolution = np.std(radius)
        else:
            resolution = 1000

        cost = np.sum(resolution)
        #There is no uncertainty in our result
        uncer = 0
        #The evaluation will always be a success
        bad = False
        #Add a small time delay to mimic a real experiment

        #The cost, uncertainty and bad boolean must all be returned as a dictionary
        #You can include other variables you want to record as well if you want
        cost_dict = {'cost':cost, 'uncer':uncer, 'bad':bad}

        return cost_dict

def main():
    #M-LOOP can be run with three commands
    filename = "learner_archive_" + str(strftime("%Y-%m-%d_%H-%M")) + ".txt"

    #First create your interface
    interface = CustomInterface()
    #Next create the controller. Provide it with your interface and any options you want to set
    controller = mlc.create_controller(interface,
                                       controller_type='neural_net',
                                       #controller_type='gaussian_process',
                                       max_num_runs = 1000,
                                       target_cost = 0.5,
                                       num_params = 5,
                                       min_boundary = [-2000,-2000,-2000,-2000,-2000],
                                       max_boundary = [0,0,0,0,0],
                                       training_type = "differential_evolution",
                                       num_training_runs = 50)
    #To run M-LOOP and find the optimal parameters just use the controller method optimize
    controller.optimize()

    #The results of the optimization will be saved to files and can also be accessed as attributes of the controller.
    print('Best parameters found:')
    best_params = controller.best_params
    best_cost = controller.best_cost
    print(best_params)
    print(best_cost)

#Ensures main is run when this code is run as a script
if __name__ == '__main__':
    main()

