#!/usr/bin/env bash

# DESCRIPTION
# sum hills 2d and 1d for traj
# i=0
# for syst in 7nei 6ths 6tht; do for lig in a300 c300 a350 c350; do cd systs/$syst/04_analysis/$lig/r$i; ../../../../../scripts/04_analysis/04c_sumhills.sh; cd ../../../../../; done; done
# i=0; for syst in 7nei 6ths 6tht 6eqe; do for lig in a300 c300 a350 c350; do ( cd systs/$syst/04_analysis/$lig/r$i; ../../../../../scripts/04_analysis/04c_sumhills.sh; cd ../../../../../ ) &; done; done; wait
# sbatch --job-name=${syst}_${lig}_sumhills --time=00:30:00 --mem-per-cpu=3750M --nodes=1 --ntasks-per-node=16 --cpus-per-task=4 --output=../../../slurm/%x.%J.log

source ~/.projects_startup.sh > /dev/null 2>&1

for file in s2d.dat sh0.dat sh1.dat; do
    if [[ -f "$file" ]]; then
        echo removing previous $file
        rm $file
    else echo reweighting $file
    fi
done

plumed sum_hills --hills HILLS --mintozero --outfile s2d.dat --bin 200,200 & # core dumped # memory limit
plumed sum_hills --hills HILLS --mintozero --outfile sh0.dat --bin 200,200 --idw h0 --kt 2.494339 &
plumed sum_hills --hills HILLS --mintozero --outfile sh1.dat --bin 200,200 --idw h1 --kt 2.494339 &
wait

rm *bck.*
