#!/bin/bash

# Check if the correct number of arguments were passed
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <potential1> [<potential2> ...]"
  exit 1
fi

# Your SIMION executable path
SIMION_PATH="/path/to/simion.exe"

# Build the argument list for potentials
POTENTIALS=""
for arg in "$@"
do
  POTENTIALS="$POTENTIALS $arg"
done

# Command to run SIMION with the given potentials, modify as necessary
# Assuming that SIMION can take potentials as command-line arguments
"$SIMION_PATH" --potential $POTENTIALS

# Alternatively, if you need to modify an input file, use something like:
# sed -i "s/potential_placeholder/$1/" input_file

# Run SIMION and redirect output to a file
"$SIMION_PATH" > simion_output.txt

# If SIMION writes its output to a specific file or method, you may not need the redirection above
# and should replace the above SIMION command as needed to suit your exact requirements.
