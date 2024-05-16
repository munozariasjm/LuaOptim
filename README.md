# SimionOptimizer

SimionOptimizer is a Julia module designed to optimize SIMION parameters using simulated annealing. This tool provides flexibility to handle a generalized number of voltages and allows users to specify voltage ranges and the maximum number of calls as optional parameters.

## Installation

To use SimionOptimizer, you need to have Julia installed. You also need the following packages:
- `Optim`
- `CSV`
- `ArgParse`
- `DataFrames`

You can add these packages using Julia's package manager:

```julia
using Pkg
Pkg.add(["Optim", "CSV", "ArgParse", "DataFrames"])
```

## Usage

### Running the Optimization

To run the optimization, use the `scripts/runner.jl` script with appropriate arguments. Here is an example command:

```sh
julia ./scripts/runner.jl --path2exec="C:\Users\EXPETIMENT\Desktop\SIMION\VMI_optimize\VMI_3.PA0" --path2save="C:\Users\EXPETIMENT\Desktop\SIMION\VMI_optimize" --num_voltages=5 --lower_bounds -2000 -2000 -2000 -2000 -2000 --upper_bounds 0 0 0 0 0 --max_calls=500
```

### Arguments

- `--path2exec`: Path to the SIMION executable.
- `--path2save`: Path to save the optimization results.
- `--num_voltages`: Number of voltages to optimize.
- `--lower_bounds`: Lower bounds for the voltages (specified as a space-separated list).
- `--upper_bounds`: Upper bounds for the voltages (specified as a space-separated list).
- `--max_calls`: (Optional) Maximum number of calls to the optimization function.

### Example

```sh
julia scripts/runner.jl --path2exec="C:\Users\EXPETIMENT\Desktop\SIMION\VMI_optimize\VMI_3.PA0" --path2save="C:\Users\EXPETIMENT\Desktop\SIMION\VMI_optimize" --num_voltages=5 --lower_bounds -2000 -2000 -2000 -2000 -2000 --upper_bounds 0 0 0 0 0 --max_calls=500
```

### Intuition into Simulated Annealing

Simulated annealing is a probabilistic optimization technique inspired by the annealing process in metallurgy, where a material is heated and then slowly cooled to decrease defects and improve its structure. In optimization, simulated annealing explores the solution space by probabilistically accepting worse solutions at the beginning (high "temperature") and gradually reducing the probability of accepting worse solutions as the optimization progresses (cooling).

Key steps in simulated annealing:
1. **Initialization**: Start with an initial solution and an initial temperature.
2. **Neighbor Selection**: Generate a neighboring solution by making a small change to the current solution.
3. **Acceptance Probability**: Calculate the acceptance probability based on the change in cost and the current temperature.
4. **Update**: Accept or reject the new solution based on the acceptance probability. Reduce the temperature.
5. **Termination**: Repeat the process until a termination condition is met (e.g., maximum iterations or temperature threshold).

This approach allows the algorithm to escape local minima and explore a broader solution space, potentially finding a global minimum.

## Module Details

### SimionOptimizer.jl

This module contains the core functions for running the optimization.

#### Functions

- `communicate(cmd::Cmd)`: Runs a command and captures its output.
- `simion_cost(params::Vector{Float64}, exec_path::String, num_voltages::Int, filename::String="out_test.txt")`: Calculates the cost based on SIMION output.
- `optimize_simion(exec_path::String, save_path::String, num_voltages::Int; initial_params::Vector{Float64}=zeros(num_voltages), lower_bounds::Vector{Float64}=fill(-2000.0, num_voltages), upper_bounds::Vector{Float64}=fill(0.0, num_voltages), max_iterations::Int=1000, max_calls::Union{Int, Nothing}=nothing)`: Runs the optimization process.

## Contributing

If you have suggestions or improvements, feel free to submit a pull request or open an issue.

### Authors

**Exotic Molecules and Atoms Lab**
**Laboratory for Nuclear Science, Massachusetts Institute of Technology**
