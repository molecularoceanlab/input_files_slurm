#!/usr/bin/env bash

# DESCRIPTION
#run hrex mtd production

source ~/.projects_startup.sh > /dev/null 2>&1

# TEST
# run=test syst=6eqe lig=amor device="-update cpu" max="-cpi -nsteps 10" time="0-00:01:00" arch="1_1" # arch="4_2"
# run=test syst=6eqe lig=amor device="-update cpu" max="-cpi -nsteps 5000" time="0-00:01:00" arch="1_1" # write the min for xtc to be created
# ../../scripts/03d_run_hrex.sh "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"

# parameters for run
run=$1      # run vs test 10 steps
syst=$2     # 6eqe
lig=$3      # amor vs crys
device=$4   # "-update cpu"
max=$5      # "-nsteps 10" "-maxh 5.5"
time=$6     # "0-06:00:00"
arch=$7     # "4_2"

nrep=8      # replicas
plumed="-plumed ../${lig}.dat"

export OMP_NUM_THREADS=$nrep            # eq MAX
export SLURM_CPUS_PER_TASK=$nrep

echo -e "\nhrex equilibrium after pulling for syst $syst"
echo -e "$pwd \n$0 $@"
echo $run $syst $lig $device $max $time $arch
echo -e "$OMP_NUM_THREADS $nrep $gmx $plumed"

# check cpt point for plumed.dat RESTART?

# PRODUCTION HREX MTD

mpiexec -np $nrep $gmx mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -noappend -ntomp $nrep -pin on $device $plumed $max

sleep 5

time_ps=$(grep -A 1 "Step           Time" $(ls r0/*log | tail -1) | tail -1 | awk '{print $2}')
finish=1000000   # 300 ns

for i in {0..7}; do 
    cpt=$(ls r$i/*cpt)
    part=$(ls r$i/*part* | awk -F "." '{print $2}' | sort -u | tail -1)
    echo $cpt $i $part
    cp r$i/hrex.cpt r$i/${part}_hrex.cpt
    cp r$i/hrex_prev.cpt r$i/${part}_hrex_prev.cpt
    ls r$i/*cpt
done

if [[ "$run" == "run" ]]; then
    if (( $(echo "$time_ps < $finish" | bc -l) )); then
        echo "$time is less than $finish. Resubmit"
        time="3-00:00:00"; max="-maxh 71.95"; run="run"; device="-cpi -update cpu -nb gpu"; arch="1_1"
        echo "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"
        ../../scripts/03e_submit_hrex.slurm "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"
    elif (( $(echo "$time_ps > $finish" | bc -l) )); then
        echo "$time_ps is greater than $finish. Stop"
    else
        echo "$time_ps equals $finish. Stop"
    fi
fi

