###############################################
# GLOBAL SEARCHER for SIMION parameters

# by: Jose Miguel Muñoz
# please contact me if this doesn't works
###############################################

###############################################
#       Packages
###############################################
using Pkg
Pkg.activate("..")
using Optim, StaticArrays, BlackBoxOptim, CSV, ArgParse, DataFrames

# path2exec = "../tools/bash_runner.sh"
# PATH2SAVE = "../RESULTS/"
parser = ArgParse.ArgumentParser()
ArgParse.add_argument(parser, "--path2exec"; help="Path to the executable")
ArgParse.add_argument(parser, "--path2save"; help="Path to save the results")

args = ArgParse.parse_args(parser)
path2exec = args.path2exec
path2save = args.path2save

###############################################
#       communicate with executable
###############################################
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

init_x = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0,]
ranges = [
    (-1, 1),
    (-1, 1),
    (-1, 1),
    (-1, 1),
    (-1, 1),
    (-1, 1),
]

function lua_caller(x::Vector)
    @show x
    exec = `bash $path2exec $x[1] $x[2] $x[3] $x[4] $x[5] $x[6]`
    χ² = parse(Float64, communicate(exec)[1])
    @show χ²
end

optf(x) = loss(x)
res = bboptimize(optf, init_x; SearchRange=ranges, NumDimensions=length(init_x))
best_candidate(res)
# Save the results
CSV.write(path2save * "results.csv", DataFrame(res), writeheader=true)