#!/bin/bash

#SBATCH -t 9:05:00
#SBATCH --job-name=p7_6_md2.cont
#SBATCH --output=%J_p7_6_md2.cont.out
#SBATCH --error=%J_p7_6_md2.cont.err

#SBATCH -n 96 # number of tasks.
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs

#SBATCH --mail-user=sdipede@icm.csic.es  

#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
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

#	step 6 MD production

cd $md/4_md

#	simulation - continuation

mpirun -np 96 $gmx mdrun -v -deffnm step06_md1 -cpi step06_md1.cpt -cpt 60 -plumed plumed.dat -maxh 9 # -nsteps 100

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.xtc -o step06_md1.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.start.pdb -dump 0

echo 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.last.pdb -dump 100000

#       return to main

cd $path
