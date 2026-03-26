#!/bin/bash

#SBATCH -t 09:05:00
#SBATCH --job-name=p7_6_md1_loop
#SBATCH --output=%J_p7_6_md1_loop.out
#SBATCH --error=%J_p7_6_md1_loop.err

#SBATCH -n 96 # number of tasks.
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs

#SBATCH --mail-user=sdipede@icm.csic.es  

#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#   #SBATCH --mail-type=REQUEUE
#   #SBATCH --mail-type=ALL


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

#	lwall max distance

#lwall_a=$((39/10))	# nm BASH CANNOT HANDLE FLOATING POINTS!!!
lwall_a=`echo '39 / 10' | bc -l`
#echo $lwall_a

#	start loop 1/2 decreasing lwall distance

for i in 0{1..9} {10..19}
do

#	make directory for each itaration and enter

mkdir $md/4_md/md_$i

cd $md/4_md/md_$i

#	create plumed input file with appropriate lwall lenght

touch plumed_$i.dat

#	dicrease lwall distance by 2 for each i

#lwall_a=$((lwall_a-=0.2)) # BASH CANNOT HANDLE FLOATING POINTS
lwall_a=`echo $lwall_a - '0.2' | bc -l`
#echo $lwall_a

#	writing plumed input file

echo -e "d1: DISTANCE ATOMS=21,53\n\
t1: TORSION ATOMS=9-12\n\
t2: TORSION ATOMS=27,28,52,51\n\
t3: TORSION ATOMS=37-40\n\n\
lwall: LOWER_WALLS ARG=d1 AT=$lwall_a KAPPA=150.0 EXP=2 EPS=1 OFFSET=0\n\
PRINT ARG=* FILE=COLVAR STRIDE=10000" >> plumed_$i.dat

#cd $md

#	end loop 1/2

#done

#	#       start loop 2/2 running time slow
#	
#for i in 0{1..9} {10..18}
#do

# enter directory

#cd $md/4_md/md_$i

#	cpp preprocess input

$gmx grompp -f $run/par/step06_md1.mdp -c $md/3_eq_npt/step05_npt.gro -r $md/3_eq_npt/step05_npt.gro -p $md/3_eq_npt/step05_npt.top -t $md/3_eq_npt/step05_npt.cpt -o step06_md1_$i.tpr -pp step06_md1_$i.top -po step06_md1_$i.mdout.mdp # -maxwarn 100

#	simulation run

#mpirun -np 96 
$gmx mdrun -v -s step06_md1_$i.tpr -deffnm step06_md1_$i -cpt 60 -plumed plumed_$i.dat -maxh 9 -nsteps 100

#	end loop 1/2

#done

#       start loop 2/2 running time slow

#for i in 0{1..9} {10..19}
#do

#       simulation continuation

#mpirun -np 96 $gmx mdrun -v -deffnm step06_md1_$i -cpi step06_md1_$i.cpt -cpt 60 -plumed plumed_$i.dat -maxh 9 # -nsteps 100

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.start.pdb -dump 0

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.last.pdb -dump 100000

# exit directory

cd $md

#	end of the loop 2/2

done

#       return to main

cd $path
