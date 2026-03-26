#!/usr/bin/env bash

#SBATCH -t 0-06:00:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=mtd
#SBATCH --output=../../slurm/%x.%J.log   # Standard output and error log

# TEST
# lig=amor max="-nsteps 10 -maxh 0.01" device=" "
# run production
# 
# ../scripts/03b_run_mtd.sh $lig $max $device
# for lig in amor crys; do cd $lig; ../scripts/03b_run_mtd.sh $lig $max $device; cd ..; done
#
# lig=amor max="-maxh 5.45" device="-nb gpu" time="0-06:00:00" --dependency=afterok:??????
# sbatch --job-name=${lig}_2PET_mtd --time="$time" ./scripts/03b_run_mtd.sh $lig $max $device
# for lig in amor crys; do cd $lig; echo $lig $PWD; sbatch --job-name=${lig}_2PET_mtd --time="$time" ../scripts/03b_run_mtd.sh $lig $max $device; cd ..; done

source ~/.projects_startup.sh > /dev/null 2>&1
export OMP_NUM_THREADS=32
gmx=gmx_mpi

lig=${1:-"amor"}                    # a300 c300
max=${2:-"-nsteps 10 -maxh 0.01"}   # -nsteps 10 or -maxh 5.95
device=${3:-""}              #"-nb gpu"
#plumed="../par_md/mtd_${lig}.dat"                 # amor.dat
plumed="mtd_${lig}.dat"                 # amor.dat

$gmx mdrun -v -deffnm mtd -dlb no -cpt 60 -cpi -noappend -pin on -update cpu -ntomp $OMP_NUM_THREADS $max -plumed $plumed $device

sleep 5

time=$(grep -A 1 "Step           Time" $(ls *log | tail -1) | tail -1 | awk '{print $2}')
finish=800000   # 300 ns

# Use bc for floating-point comparison
if (( $(echo "$time < $finish" | bc -l) )); then
    echo "$time is less than $finish. Resubmit"
    time="0-06:00:00"; max="-maxh 5.95"; device="-nb gpu"
    echo "$lig" "$max" "$device" "$time"
    sbatch --job-name=${lig}_2PET_mtd --time="$time" ../scripts/03b_run_mtd.sh "$lig" "$max" "$device"
elif (( $(echo "$time > $finish" | bc -l) )); then
    echo "$time is greater than $finish. Stop"
else
    echo "$time equals $finish. Stop"
fi
