#!/bin/bash

#SBATCH -t 2:10:00
#SBATCH --job-name=p7_3-5_2min.heat.eq
#SBATCH --output=%J_p7_3-5_2min.heat.eq.out
#SBATCH --error=%J_p7_3-5_2min.heat.eq.err

#SBATCH -n 96 # number of tasks.
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs

#SBATCH --mail-user=sdipede@icm.csic.es  

#SBATCH --mail-type=BEGIN
#   #SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#   #SBATCH --mail-type=REQUEUE
#   #SBATCH --mail-type=ALL


cd ..

#	cesga modules
module load cesga/2020
module load gcc/system openmpi/4.0.5 gromacs/2021-PLUMED-2.7.1

# variables
now=$(date)
gmx=gmx_mpi                                        # gmx executable
lustre=/mnt/lustre/scratch/home/csic/eyg/sdp
store=/mnt/netapp1/Store_CSIC/home/csic/eyg/sdp
home=/mnt/netapp2/Home_FT2/home/csic/eyg/sdp
exp=7_HEMTx4_lwall

path=$PWD
run=$PWD/0_run
insy=$PWD/1_init_syst
md=$PWD/2_md
an=$PWD/3_anal
del=$PWD/del

#	step 3	MIN

cd $md/1_min

#	run parameter input

# $gmx grompp -f $run/par/step03_min1.mdp -c $insy/str/step02_solv.gro -r $insy/str/step02_solv.gro -p $insy/top/step00_syst.top -o step03_min1.tpr -pp step03_min1.top -po step03_min1.mdout.mdp # -maxwarn 100

#	simulation

#mpirun -np 96 
#$gmx mdrun -v -s step03_min1.tpr -deffnm step03_min1 -cpt 60 -plumed $md/plumed.dat -nsteps 100

#	continuation

#mpirun -np 96 
$gmx mdrun -v -deffnm step03_min1 -cpi step03_min1.cpt -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#	quick analysis

echo 10 0 | $gmx energy -f step03_min1.edr -o step03_min1.xvg

#	concat traj
#gmx trjcat -f step08*_md*.xtc -o step08_md.all.xtc

#	wrap 2 steps

echo 2 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.trr -o step03_min1.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.fit.xtc -fit rot+trans

#	dump first and last frames

echo 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.start.pdb -dump 0

echo 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.last.pdb -dump 50000

#       step 4  HEAT NVT

cd $md/2_heat_nvt

#	run input parameter

#$gmx grompp -f $run/par/step04_nvt.mdp -c $md/1_min/step03_min1.gro -r $md/1_min/step03_min1.gro -p $md/1_min/step03_min1.top -o step04_nvt.tpr -pp step04_nvt.top -po step04_nvt.mdout.mdp # -maxwarn 100

#	simulation

#mpirun -np 96 
#$gmx mdrun -v -s step04_nvt.tpr -deffnm step04_nvt -cpt 60 -plumed $md/plumed.dat -nsteps 100

#	continuation

$gmx mdrun -v -deffnm step04_nvt -cpi step04_nvt.cpt -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#	quick analysis

echo 14 0 | $gmx energy -f step04_nvt.edr -o step04_nvt.xvg

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step04_nvt.tpr -f step04_nvt.xtc -o step04_nvt.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step04_nvt.tpr -f step04_nvt.center.xtc -o step04_nvt.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step04_nvt.tpr -f step04_nvt.center.xtc -o step04_nvt.start.pdb -dump 0

echo 0 | gmx trjconv -s step04_nvt.tpr -f step04_nvt.center.xtc -o step04_nvt.last.pdb -dump 250000

#       step 5  EQ NPT

cd $md/3_eq_npt

#	run input parameters - continuation!!!

#$gmx grompp -f $run/par/step05_npt.mdp -c $md/2_heat_nvt/step04_nvt.gro -r $md/2_heat_nvt/step04_nvt.gro -p $md/2_heat_nvt/step04_nvt.top -t $md/2_heat_nvt/step04_nvt.cpt -o step05_npt.tpr -pp step05_npt.top -po step05_npt.mdout.mdp # -maxwarn 100

#	simulation - contiuation!!!

#mpirun -np 96 
#$gmx mdrun -v -s step05_npt.tpr -deffnm step05_npt -cpt 60 -plumed $md/plumed.dat -nsteps 100

#	continuation

$gmx mdrun -v -deffnm step05_npt -cpi step05_npt.cpt -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#	quick analysis

echo 15 20 21 | $gmx energy -f step05_npt.edr -o step05_npt.xvg

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step05_npt.tpr -f step05_npt.xtc -o step05_npt.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step05_npt.tpr -f step05_npt.center.xtc -o step05_npt.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step05_npt.tpr -f step05_npt.center.xtc -o step05_npt.start.pdb -dump 0

echo 0 | gmx trjconv -s step05_npt.tpr -f step05_npt.center.xtc -o step05_npt.last.pdb -dump 50000

#	return to main

cd $path
