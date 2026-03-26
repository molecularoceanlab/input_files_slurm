#!/usr/bin/env bash

#SBATCH -t 0-01:00:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=pull
#SBATCH --output=../../slurm/%x.%J.log   # Standard output and error log

# run production
# for lig in amor crys; do cd systs/02_mineq/pull_${lig}; ../../../scripts/02d_run_pull.sh $lig "-nsteps 10" " "; cd ../../../; done
# for lig in amor crys; do cd systs/02_mineq/pull_${lig}; sbatch --job-name=${lig}_pull --time=00:30:00 ../../../scripts/02d_run_pull.sh $lig "-maxh 0.45" "-nb gpu"; cd ../../../; done
# for lig in amor crys; do cd ${lig}; ../scripts/02d_run_pull.sh $lig "-nsteps 10" " "; cd .. ; done
# for lig in amor crys; do cd ${lig}; sbatch --job-name=${lig}_pull --time=01:00:00 ../scripts/02d_run_pull.sh $lig "-maxh 0.95" "-nb gpu"; cd .. ; done

source ~/.projects_startup.sh > /dev/null 2>&1
export OMP_NUM_THREADS=32
gmx=gmx_mpi

lig=${1:-"amor"}                    # amor crys
max=${2:-"-nsteps 10 -maxh 0.01"}   # -nsteps 10 or -maxh 5.95
device=${3:-"-nb gpu"}              #"-nb gpu"
plumed="../../../par_md/pull_${lig}.dat" # a300.dat

#$gmx mdrun -v -deffnm pull -dlb no -cpt 60 -cpi -noappend -pin on -update cpu -ntomp $OMP_NUM_THREADS -plumed $plumed $max $device
$gmx mdrun -v -deffnm pull -dlb no -cpt 60 -cpi -pin on -update cpu -ntomp $OMP_NUM_THREADS -plumed $plumed $max $device
# BETTER WITH APPENDING FOR FILE HANDLING. noappend only on large trajectories
