#!/usr/bin/env bash

#SBATCH -t 0-00:10:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=1 # 16 inefficient for gmx
#SBATCH --cpus-per-task=32  # max 10 for gmx but cesga make it mandatory to use all
#SBATCH --gres=gpu
#SBATCH --job-name=mineq
#SBATCH --output=../slurm/%x.%J.log   # Standard output and error log

#   DESCRIPTION
#   run MIN and EQ
#   from systs/$syst/02_mineq/ directory
#   test on one syst with 10 steps
#   ../../../scripts/02_mineq/02b_mineq.sh "-nsteps 10"
#   10 steps for all systems
#   for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ls; echo $syst; ../../../scripts/02_mineq/02b_mineq.sh "-nsteps 10"; ls; cd ../../..; fi; done
#   slurm jon on cesga. no need for maxh in quick simulations
#   for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ls; echo $syst; sbatch --job-name=${syst}_mineq ../../../scripts/02_mineq/02b_mineq.sh ; ls; cd ../../..; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1
export OMP_NUM_THREADS=32

templates=../../../templates
par_md=../../../par_md
gmx=gmx_mpi
option=$1   # "-nsteps 10" "-maxh 0.10" # 0.10 hs > 9 min

#   MIN

$gmx grompp -f $templates/par_md/1_min.mdp -c ../01_sysprep/ions.gro -p ../01_sysprep/posres.top -o min.tpr -pp min.top -po min_out.mdp -maxwarn 1
$gmx mdrun -v -s min.tpr -deffnm min -cpt 60 -pin on -ntomp $OMP_NUM_THREADS -cpi -update cpu $option

#   EQ

$gmx grompp -f $par_md/eq.mdp -n ../01_sysprep/complex.ndx -c min.gro -r min.gro -p ../01_sysprep/posres.top -o eq.tpr -pp eq.top -po eq_out.mdp -maxwarn 1
$gmx mdrun -v -s eq.tpr -deffnm eq -cpt 60 -pin on -ntomp $OMP_NUM_THREADS -cpi -update cpu $option

rm *#*#*
