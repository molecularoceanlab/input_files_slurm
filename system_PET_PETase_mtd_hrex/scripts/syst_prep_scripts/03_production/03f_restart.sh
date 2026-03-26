#!/usr/bin/env bash

# DESCRIPTION
# find last checkpoint steps
# cut simulation to last prev_checkpoint for async replicas
#
# run="test" syst="7nei" lig="crys" device="-update cpu" max="-nsteps 10 -maxh 5.5" time="0-06:00:00" arch=2
# cd systs/$syst/03_production/$lig/; ../../../../scripts/03_production/03f_restart.sh "$run" "$syst" "$lig" "$device" "$max" "$time" "$arch"; cd ../../../../

source ~/.projects_startup.sh > /dev/null 2>&1

# check cpt point for plumed.dat RESTART?

#rm async.steps sync.steps
#
#for i in {0..7}; do
#    gmx dump -cp r${i}/hrex.cpt
#done | grep "step = " | grep "step = " > cpt.steps
#
#for i in {0..7}; do
#    gmx dump -cp r${i}/hrex_prev.cpt
#done | grep "step = " | grep "step = " > prev_cpt.steps

#cpt=$(cat cpt.steps | sort -u | awk '{print $3}')
#prev_cpt=$(cat prev_cpt.steps | sort -u | awk '{print $3}')
#TIMESTEP=0.002
#TIME_PS=$(echo "$prev_cpt * $TIMESTEP" | bc) # time_ps = 443069300 * 0.002 = 886138.6 ps
#
#for i in {0..7}; do
#	(
##    cp r${i}/hrex_prev.cpt r${i}/hrex_prev_bk.cpt
##	gmx trjcat -f r${i}/hrex.part*.xtc -o r${i}/hrex.xtc
##    gmx trjconv -f r${i}/hrex.xtc -o r${i}/hrex_prev.xtc -e $TIME_PS
##    gmx eneconv -f r${i}/hrex.part*.edr -o r${i}/hrex_prev.edr -e $TIME_PS
#    gmx check -f r${i}/hrex_prev.xtc
#	)
#done
#wait

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

# TEST 10 STEPS from prev checkpoint for async broken simulations
# -cpi hrex_prev.cpt # instead of -cpi (hrex.cpt)

mpiexec -np $nrep $gmx mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -cpi hrex_prev.cpt -noappend -ntomp $nrep -pin on $plumed $max $device

