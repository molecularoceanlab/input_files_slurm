#!/usr/bin/env bash

#SBATCH -t 0-06:00:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=mineq
#SBATCH --output=../slurm/%x.%J.log   # Standard output and error log

# run on cluster mineq
# cd systs/02_mineq; ./scripts/02b_mineq_run.sh "-nsteps 10"; cd ../../
# cd systs/02_mineq; sbatch --job-name=mineq_2PETs ./scripts/02b_mineq_run.sh "-maxh 5.9 -nb gpu"; cd ../../

source ~/.projects_startup.sh > /dev/null 2>&1
export OMP_NUM_THREADS=32

par_md=par_md
gmx=gmx_mpi
option=$1   # "-nsteps 10" "-maxh 0.2 -nb gpu" # 0.2 hs > 12 min

#   #   MIN
#   
#   $gmx grompp -f $par_md/2a_min.mdp -c ../01_sysprep/solv.gro -p ../01_sysprep/solv.top -o min.tpr -pp min.top -po min_out.mdp -maxwarn 1
#   $gmx mdrun -v -s min.tpr -deffnm min -cpt 60 -pin on -ntomp $OMP_NUM_THREADS -cpi -update cpu $option
#   
#   sleep 2
#   
#      #   HEAT
#      
#   $gmx grompp -f $par_md/2b_nvt.mdp -c min.gro -p min.top -o nvt.tpr -pp nvt.top -po nvt_out.mdp -maxwarn 1 # -r min.gro 
#   $gmx mdrun -v -s nvt.tpr -deffnm nvt -cpt 60 -pin on -ntomp $OMP_NUM_THREADS -cpi -update cpu $option
#   
#   sleep 2

#   EQ

#$gmx grompp -f $par_md/2c_npt.mdp -c nvt.gro -p nvt.top -o npt.tpr -pp npt.top -po npt_out.mdp -maxwarn 1 # -r nvt.gro 
#$gmx grompp -f $par_md/2d_npt_stretch.mdp -c nvt.gro -p nvt.top -o npt.tpr -pp npt.top -po npt_out.mdp -maxwarn 1 # -r nvt.gro 
$gmx mdrun -v -s npt.tpr -deffnm npt -cpt 60 -pin on -ntomp $OMP_NUM_THREADS -cpi -update cpu -plumed par_md/stretch.dat $option

sleep 2

rm *#*#*
