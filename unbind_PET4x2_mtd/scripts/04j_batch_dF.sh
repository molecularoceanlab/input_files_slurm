#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

lig=${1:-"crys"}
stride=${2:-1000}

# Ensure the output directory exists
mkdir -p $lig/s${stride}/dF

cd $lig/s${stride}

# Read combinations from fes_ranges.txt and run analysis for each
while read minA maxA minB maxB; do
    echo "Running analysis for minA=$minA, maxA=$maxA, minB=$minB, maxB=$maxB..."
    ../../scripts/04i_analyze_FES.sh "$minA" "$maxA" "$minB" "$maxB" > "dF/dF_${minA}_${maxA}_${minB}_${maxB}.dat"
done < ../dF_ranges_${lig}.txt

cd ../..

echo "All analyses completed!"

