#!/bin/bash

#       #       cesga modules ft2
#module load cesga/2020
#module load gcc/system openmpi/4.0.5 gromacs/2021-PLUMED-2.7.1

#		cesga ft3

module load cesga/2020 gcc/system openmpi/4.0.5_ft3_cuda gromacs/2021.4-plumed-2.8.0

#       
#       # variables
gmx=gmx_mpi                                        # gmx executable

cd ..

path=$PWD
lustre=/mnt/lustre/scratch/home/csic/eyg/sdp
store=/mnt/netapp1/Store_CSIC/home/csic/eyg/sdp
home=/mnt/netapp2/Home_FT2/home/csic/eyg/sdp
run=$PWD/0_run
insy=$PWD/1_init_syst
md=$PWD/2_md
an=$PWD/3_anal
del=$PWD/del

for i in 0{1..9} {10..19}; do	# done at the end of echo command!!!!!!!

#	
cd $md/4_md/md_$i
#	

echo 2 2 | $gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.dry.center.xtc -center -pbc mol -ur compact
#       
echo 2 2 | $gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.dry.center.xtc -o step06_md1_$i.dry.fit.xtc -fit rot+trans
#       
#       #       dump first and last frames
#
#	echo -e "0 & ! a H*\nq"
#	echo -e "1 | 13\nq"
       
echo 2 | $gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.dry.center.xtc -o step06_md1_$i.dry.start.pdb -dump 0

#	
done

#	touch job.$i.slurm
#	
#	chmod +x job.$i.slurm
#	
#	echo -e "#!/bin/bash
#	
#	#SBATCH -t 04:05:00
#	#SBATCH --job-name=p7.$i.md3.cont
#	#SBATCH --output=%J.%x.out
#	#SBATCH --error=%J.%x.err
#	
#	#SBATCH -n 96 # number of tasks.
#	#SBATCH --ntasks-per-node=24 # number of tasks per node
#	#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs
#	
#	#SBATCH --mail-user=sdipede@icm.csic.es  
#	
#	#	#SBATCH --mail-type=BEGIN
#	#	#SBATCH --mail-type=END
#	#	#SBATCH --mail-type=FAIL
#	#	#SBATCH --mail-type=REQUEUE
#	#	#SBATCH --mail-type=ALL
#	
#	
#	#	from job md directory	cd ..	#	from main directory (slurm from run directory)
#	
#	#	cesga modules
#	module load cesga/2020
#	module load gcc/system openmpi/4.0.5 gromacs/2021-PLUMED-2.7.1
#	
#	# variables
#	#	now=$(date)
#	gmx=gmx_mpi                                        # gmx executable
#	lustre=/mnt/lustre/scratch/home/csic/eyg/sdp
#	store=/mnt/netapp1/Store_CSIC/home/csic/eyg/sdp
#	home=/mnt/netapp2/Home_FT2/home/csic/eyg/sdp
#	exp=7_HEMTx4_lwall
#	
#	path=/mnt/lustre/scratch/home/csic/eyg/sdp/7_HEMTx4_lwall_flex
#	run=\$path/0_run
#	insy=\$path/1_init_syst
#	md=\$path/2_md
#	an=\$path/3_anal
#	del=\$path/del
#	
#	###	step 6 MD simulation loop
#	
#	###	PLUMED LWALL MD SIMULATION
#	
#	#	start loop decreasing lwall distance
#	
#	#		NEXT TIME USE SRUN!!!!!! TO PARALLELIZE NON DEPENDENT JOBS!!!!
#	
#	#	simulation continuation
#	
#	mpirun -np 96 \$gmx mdrun -v -deffnm step06_md1_$i -cpi step06_md1_$i.cpt -cpt 60 -plumed plumed_$i.dat -maxh 4 #-nsteps 100
#	
#	#       wrap 2 steps
#	
#	echo 2 0 | \$gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.center.xtc -center -pbc mol -ur compact
#	
#	echo 2 0 | \$gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.fit.xtc -fit rot+trans
#	
#	#       dump first and last frames
#	
#	echo 0 | \$gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.start.pdb -dump 0
#	
#	echo 0 | \$gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.last.pdb -dump 100000" > job.$i.slurm
#	
#	done
