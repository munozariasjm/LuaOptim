using Pkg
Pkg.activate("./src/optimizer.jl")
using ArgParse
using SimionOptimizer

# Argument Parsing
parser = ArgParse.ArgumentParser()
ArgParse.add_argument(parser, "--path2exec"; help="Path to the executable")
ArgParse.add_argument(parser, "--path2save"; help="Path to save the results")
ArgParse.add_argument(parser, "--num_voltages"; help="Number of voltages", type=Int)
ArgParse.add_argument(parser, "--lower_bounds"; help="Lower bounds for voltages", nargs="+", type=Float64, default=fill(-2000.0, 5))
ArgParse.add_argument(parser, "--upper_bounds"; help="Upper bounds for voltages", nargs="+", type=Float64, default=fill(0.0, 5))
ArgParse.add_argument(parser, "--max_calls"; help="Maximum number of calls", type=Int, default=nothing)
args = ArgParse.parse_args(parser)

path2exec = args.path2exec
path2save = args.path2save
num_voltages = args.num_voltages
lower_bounds = args.lower_bounds
upper_bounds = args.upper_bounds
max_calls = args.max_calls

# Ensure bounds match the number of voltages
if length(lower_bounds) != num_voltages
    error("The number of lower bounds does not match the number of voltages.")
end

if length(upper_bounds) != num_voltages
    error("The number of upper bounds does not match the number of voltages.")
end

# Run the optimization
SimionOptimizer.optimize_simion(path2exec, path2save, num_voltages; lower_bounds=lower_bounds, upper_bounds=upper_bounds, max_calls=max_calls)
