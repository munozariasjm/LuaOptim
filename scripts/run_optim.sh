#!/bin/bash

# Linux script to run SIMION with a list of potentials.
PATH2SIMION="\path\to\simion.exe"
PATH2SAVE="\path\to\savefile"
PATH2optimizer="\path\to\optimizer.jl"

# RUN THE JULIA OPTIMIZER
julia $PATH2optimizer $PATH2SIMION $PATH2SAVE