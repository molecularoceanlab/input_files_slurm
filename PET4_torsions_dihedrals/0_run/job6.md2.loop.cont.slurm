#!/bin/bash

#SBATCH -t 04:05:00
#SBATCH --job-name=p7_6_md2_loop.cont
#SBATCH --output=%J_p7_6_md2_loop.cont.out
#SBATCH --error=%J_p7_6_md2_loop.cont.err

#SBATCH -n 96 # number of tasks.
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs

#SBATCH --mail-user=sdipede@icm.csic.es  

#	#SBATCH --mail-type=BEGIN
#	#SBATCH --mail-type=END
#	#SBATCH --mail-type=FAIL
#	#SBATCH --mail-type=REQUEUE
#	#SBATCH --mail-type=ALL


cd ..	#	from main directory (slurm from run directory)

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

###	step 6 MD simulation loop

###	PLUMED LWALL MD SIMULATION

#	start loop decreasing lwall distance

for i in 0{1..9} {10..19}; do
#for i in 04 06 0{7..9} {10..19}
do

#i=0$((6))
#i=0$((7))
#i=0$((8))
#i=0$((9))
#i=$((10))
#i=$((11))
#i=$((12))
#i=$((13))
#i=$((14))
#i=$((15))
#i=$((16))
#i=$((17))
#i=$((18))
#i=$((19))

#		NEXT TIME USE SRUN!!!!!! TO PARALLELIZE NON DEPENDENT JOBS!!!!


#	for each itaration enter

cd $md/4_md/md_$i

#	simulation continuation

mpirun -np 96 $gmx mdrun -v -deffnm step06_md1_$i -cpi step06_md1_$i.cpt -cpt 60 -plumed plumed_$i.dat -maxh 4 #-nsteps 100

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.start.pdb -dump 0

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.last.pdb -dump 100000

#	end of the loop

done

#       return to main

cd $path
