#!/usr/bin/env bash
  
#SBATCH -t 0-06:00:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=md_tors
#SBATCH --output=../../slurm/%x.%J.log   # Standard output and error log

source ~/.projects_startup.sh > /dev/null 2>&1
export OMP_NUM_THREADS=32
gmx=gmx_mpi

i=${1:-"00"}						# 01,02...
max=${2:-"-nsteps 10 -maxh 0.01"}	# -nsteps 10 or -maxh 5.95
device=${3:-""}						#"-nb gpu"
plumed="plumed_${i}.dat"			# amor.dat

# RUN
# i="00" max="-nsteps 10 -maxh 0.01" device=""
# ../../../0_run/job9.md2.newrun.slurm "$i" "$max" "$device"

$gmx mdrun -v -deffnm step06_md1_$i -dlb no -cpt 60 -cpi -pin on -update cpu -ntomp $OMP_NUM_THREADS $max -plumed $plumed $device

sleep 5

time=$(grep -A 1 "Step           Time" $(ls *log | tail -1) | tail -1 | awk '{print $2}')
finish=100000   # 300 ns

# Use bc for floating-point comparison
if (( $(echo "$time < $finish" | bc -l) )); then
    echo "$time is less than $finish. Resubmit"
    time="0-06:00:00"; max="-maxh 5.95"; device="-nb gpu"
    echo "$i" "$max" "$device" "$time"
    sbatch --job-name="md_${i}" --time="$time" ../../../0_run/job9.md2.newrun.slurm "$i" "$max" "$device"
elif (( $(echo "$time > $finish" | bc -l) )); then
    echo "$time is greater than $finish. Stop"
else
    echo "$time equals $finish. Stop"
fi

# WRAP

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.center.xtc -center -pbc mol -ur compact
echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.fit.xtc -fit rot+trans
echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.start.pdb -dump 0

rm *#*#* bck* *center*
