#!/usr/bin/env bash

# DESCRIPTION
#run eq2 production

source ~/.projects_startup.sh > /dev/null 2>&1

# TEST
# run=test syst=6eqe lig=crys device="-update cpu" max="-nsteps 10" time="0-00:01:00" arch="1_1"
# ../scripts/02d_eq2_stretch_run.sh "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"

# parameters for run
run=$1      # run vs test 10 steps
syst=$2     # 6eqe
lig=$3      # amor vs crys
device=$4   # "-update cpu"
max=$5      # "-nsteps 10" "-maxh 5.5"
time=$6     # "0-06:00:00"
arch=$7     # "4_2"

nrep=8      # replicas
plumed="-plumed eq2_${lig}.dat"

export OMP_NUM_THREADS=$nrep            # eq MAX
export SLURM_CPUS_PER_TASK=$nrep

# check cpt point for plumed.dat RESTART?

# PRODUCTION MTD

$gmx mdrun -v -deffnm eq2 -dlb no -cpt 60 -cpi -noappend -ntomp $nrep -pin on $device $plumed $max

sleep 5

time=$(grep -A 1 "Step           Time" $(ls *log | tail -1) | tail -1 | awk '{print $2}')
finish=100000   # 300 ns

if [[ "$run" == "run" ]]; then
    if (( $(echo "$time < $finish" | bc -l) )); then
        echo "$time is less than $finish. Resubmit"
    	time="0-06:00:00"; max="-maxh 5.95"; run="run"; device="-update cpu -nb gpu"; arch="1_1"
    	echo "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"
    	../scripts/02e_eq2_stretch_submit.slurm "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"
    elif (( $(echo "$time > $finish" | bc -l) )); then
        echo "$time is greater than $finish. Stop"
    else
        echo "$time equals $finish. Stop"
    fi
fi
