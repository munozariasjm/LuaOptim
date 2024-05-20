module SimionOptimizer

using Optim, CSV, ArgParse, DataFrames

export optimize_simion, communicate

function communicate(cmd::Cmd)
    out = Pipe()
    err = Pipe()
    process = run(pipeline(ignorestatus(cmd), stdout=out, stderr=err))
    close(out.in)
    close(err.in)
    stdout = @async String(read(out))
    stderr = @async String(read(err))
    (stdout=String(read(out)),
        stderr=String(read(err)),
        code=process.exitcode)
end

function simion_cost(params::Vector{Float64}, exec_path::String, num_voltages::Int, filename::String="out_test.txt")
    V = params

    if isfile(filename)
        rm(filename)
    end

    # Construct the command to call SIMION
    voltage_str = join([string(i, "=", V[i]) for i in 1:num_voltages], ",")
    cmd1 = `powershell.exe & '.\SIMION 8.1.lnk' --nogui fastadj $exec_path $voltage_str`
    cmd2 = `powershell.exe & '.\SIMION 8.1.lnk' --nogui fly --restore-potentials=0 --recording-output=$filename $exec_path`

    run(cmd1)
    run(cmd2)

    total_time = 0.0
    while total_time < 10.0
        if isfile(filename)
            data = readdlm(filename, skipstart=1)[:, 1]
            if length(data) == 1000
                break
            else
                sleep(0.2)
                total_time += 0.2
            end
        else
            sleep(0.2)
            total_time += 0.2
        end
    end

    if isfile(filename) && length(data) == 1000
        data_simion = readdlm(filename, skipstart=1)
        idx = findall(x -> x == 50, data_simion[:, 1])
        data_simion = data_simion[idx, :]
        pos_y = data_simion[:, 2]
        pos_z = data_simion[:, 3]
        radius = sqrt.(pos_y .^ 2 .+ pos_z .^ 2)
        resolution = length(data_simion) < 900 ? 1000 : std(radius)
    else
        resolution = 1000
    end

    return resolution
end

function optimize_simion(exec_path::String, save_path::String, num_voltages::Int;
    initial_params::Vector{Float64}=zeros(num_voltages),
    lower_bounds::Vector{Float64}=fill(-2000.0, num_voltages),
    upper_bounds::Vector{Float64}=fill(0.0, num_voltages),
    max_iterations::Int=1000,
    max_calls::Union{Int,Nothing}=nothing)

    # Define the optimization problem
    opt_problem = OptimizationFunction(params -> simion_cost(params, exec_path, num_voltages), OptimizationFunctionTraits())

    options = Optim.Options(iterations=max_iterations)
    if max_calls !== nothing
        options = Optim.Options(iterations=max_iterations, max_eval_calls=max_calls)
    end

    opt_result = optimize(opt_problem, lower_bounds, upper_bounds, initial_params, SimulatedAnnealing(), options)

    best_params = Optim.minimizer(opt_result)
    best_cost = Optim.minimum(opt_result)

    println("Best parameters found:")
    println(best_params)
    println("Best cost:")
    println(best_cost)

    # Save the results
    results_df = DataFrame([("Parameter_$i" => best_params[i]) for i in 1:num_voltages]..., :Cost => best_cost)
    CSV.write(joinpath(save_path, "results.csv"), results_df)
end

end
