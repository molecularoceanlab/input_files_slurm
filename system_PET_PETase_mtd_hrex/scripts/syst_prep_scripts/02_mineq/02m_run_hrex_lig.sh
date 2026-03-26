#!/usr/bin/env bash

# DESCRIPTION
#run hrex for ligand equilibrium after pulling
#parallel mpi over gpus by slurm on cesga
#standard slurm parameters
# run="test" syst="7nei" device="-update cpu" max="-nsteps 10 -maxh 5.5" time="0-06:00:00" arch=2
#cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02m_run_hrex_lig.sh "$run" "$syst" "$device" "$max" "$time" "$arch"; cd ../../../../
#run using scripts/02_mineq/02n_submit_hrex_lig.slurm
# syst=7nei
# cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02n_submit_hrex_lig.slurm "$run" "$syst" "$device" "$max" "$time" "$arch"; cd ../../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/SCRIPT ARGs; cd ../../../../; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

# parameters for run
run=$1
syst=$2
device=$3
max=$4
time=$5
arch=$6

nrep=8      # replicas
plumed="-plumed ../hrex.dat"

export OMP_NUM_THREADS=$nrep            # eq MAX
export SLURM_CPUS_PER_TASK=$nrep

echo -e "\nhrex equilibrium after pulling for syst $syst"
echo -e "$pwd \n$0 $@"
echo $run $syst $device $max $time $arch
echo -e "$OMP_NUM_THREADS $nrep $gmx $plumed"

# check cpt point for plumed.dat RESTART?

# PRODUCTION HREX EQ

mpiexec -np $nrep $gmx mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -cpi -noappend -ntomp $nrep -pin on $plumed $max $device
