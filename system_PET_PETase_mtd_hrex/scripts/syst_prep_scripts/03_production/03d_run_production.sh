#!/usr/bin/env bash

# DESCRIPTION
#run hrex mtd production
#parallel mpi over gpus by slurm on cesga
#standard slurm parameters
#run using scripts/03_production/03e_submit_production.slurm
#
# run="test" syst="7nei" lig="amor" device="-update cpu" max="-nsteps 10 -maxh 5.5" time="0-06:00:00" arch=2
#cd systs/$syst/03_production/$lig/; ../../../../scripts/03_production/03d_run_production.sh "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"; cd ../../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys; do cd systs/$syst/03_production/$lig/; ../../../../scripts/03_production/03d_run_production.sh "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"; cd ../../../../; done; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

# parameters for run
run=$1
syst=$2
lig=$3
device=$4
max=$5
time=$6
arch=$7

nrep=8      # replicas
plumed="-plumed ../../${lig}.dat"

export OMP_NUM_THREADS=$nrep            # eq MAX
export SLURM_CPUS_PER_TASK=$nrep

echo -e "\nhrex equilibrium after pulling for syst $syst"
echo -e "$pwd \n$0 $@"
echo $run $syst $lig $device $max $time $arch
echo -e "$OMP_NUM_THREADS $nrep $gmx $plumed"

# check cpt point for plumed.dat RESTART?

# PRODUCTION HREX MTD

mpiexec -np $nrep $gmx mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -cpi -noappend -ntomp $nrep -pin on $plumed $max $device
