#!/usr/bin/env bash

#SBATCH -t 0-06:00:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=8  # 1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=4    # 32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=hrex_2pets
#SBATCH --output=../../slurm/%x.%J.log   # Standard output and error log

# TEST
# lig=hr_a run="test" max="-nsteps 10 -maxh 0.01" device="-cpi -update cpu"
# run production
# 
# ../scripts/03f_run_hrex.sh $lig $max $device
# for lig in hr_a hr_cº; do cd $lig; ../scripts03f_run_hrex.sh $lig $max $device; cd ..; done
#
# #--dependency=afterok:??????
# lig=hr_a run="test" max="-maxh 5.45" device="-cpi -update cpu -nb gpu" time="0-06:00:00"
# sbatch --job-name=${lig}_2PET_hrex --time="$time" ./scripts/03f_run_hrex.sh $run $lig $max $device
# for lig in hr_a hr_c; do cd $lig; echo $lig $PWD; sbatch --job-name=${lig}_2PET_hrex --time="$time" ../scripts/03f_run_hrex.sh $run $lig $max $device; cd ..; done

source ~/.projects_startup.sh > /dev/null 2>&1

nrep=8
gmx=gmx_mpi

export OMP_NUM_THREADS=$nrep    #32
export SLURM_CPUS_PER_TASK=$nrep

run=${1:-"test"}
lig=${2:-"hr_a"}                    # a300 c300
max=${3:-"-nsteps 10 -maxh 0.01"}   # -nsteps 10 or -maxh 5.95
device=${4:-"-cpi -update cpu"}              #"-nb gpu"
#plumed="../par_md/mtd_${lig}.dat"                 # amor.dat
plumed="-plumed ../${lig}.dat"                 # amor.dat

# PRODUCTION HREX MTD

mpiexec -np $nrep $gmx mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -noappend -ntomp $nrep -pin on $device $plumed $max

sleep 5

time_ps=$(grep -A 1 "Step           Time" $(ls r0/*log | tail -1) | tail -1 | awk '{print $2}')
finish=800000   # 300 ns

for i in {0..7}; do
    cpt=$(ls r$i/*cpt)
    part=$(ls r$i/*part* | awk -F "." '{print $2}' | sort -u | tail -1)
    echo $cpt $i $part
    cp r$i/hrex.cpt r$i/${part}_hrex.cpt
    cp r$i/hrex_prev.cpt r$i/${part}_hrex_prev.cpt
    ls r$i/*cpt
done

# Use bc for floating-point comparison
if [[ "$run" == "run" ]]; then
	if (( $(echo "$time_ps < $finish" | bc -l) )); then
		echo "$time is less than $finish. Resubmit"
		time="3-00:00:00"; max="-maxh 71.95"; device="-cpi -updata cpu -nb gpu"; run="run"
		echo "$lig" "$max" "$device" "$time"
		sbatch --job-name=${lig}_2PET_hrex --time="$time" ../scripts/03f_run_hrex.sh "$run" "$lig" "$max" "$device"
	elif (( $(echo "$time > $finish" | bc -l) )); then
		echo "$time is greater than $finish. Stop"
	else
		echo "$time equals $finish. Stop"
	fi
fi
