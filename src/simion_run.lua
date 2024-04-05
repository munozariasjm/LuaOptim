simion.workbench_program()

-- Define position thresholds
local xcross = 134
local xcrosstotal = 395.5

-- Tables to store last positions for each ion
local xlast = {}
local xlast_t = {}

-- Counters for efficiency calculation
local count = 0
local total_count = 0

-- Declare variables for potentials (to be obtained from command line)
local Vl1, Vl2

-- Initialize from command line arguments
if #arg >= 2 then
    Vl1 = tonumber(arg[1])
    Vl2 = tonumber(arg[2])
else
    error("Please provide Vl1 and Vl2 as command line arguments.")
end

print('N       Nt     eta(%)    Vl1      Vl2')

-- Initialize run segment
function segment.initialize_run()
    count = 0
    total_count = 0
    xlast = {}
    xlast_t = {}

    -- You might need to set the potentials in SIMION here
    -- Adjust/Set the potential or other parameters in SIMION if necessary
    -- simion.pas.pa_instance[1].adjustable.Electrode1 = Vl1
    -- simion.pas.pa_instance[1].adjustable.Electrode2 = Vl2
end

-- Other actions segment
function segment.other_actions()
    if ((xlast_t[ion_number] or ion_px_mm) < xcrosstotal) == (ion_px_mm >= xcrosstotal) then
        total_count = total_count + 1
    end
    xlast_t[ion_number] = ion_px_mm

    if ((xlast[ion_number] or ion_px_mm) < xcross) == (ion_px_mm >= xcross) then
        if (ion_py_mm - 139.95)^2 + (ion_pz_mm - 139.51)^2 < (3.75)^2 then
            count = count + 1
        end
    end
    xlast[ion_number] = ion_px_mm
end

-- Terminate run segment
function segment.terminate_run()
    local transmission = 100 * count / total_count
    if transmission - math.floor(transmission) < 0.5 then
        transmission = math.floor(transmission)
    else
        transmission = math.ceil(transmission)
    end

    print(string.format('%d       %d     %d%%       %f      %f', count, total_count, transmission, Vl1, Vl2))
end
