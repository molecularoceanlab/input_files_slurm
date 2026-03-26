#!/bin/bash

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

#	step0
#	generate structure and topology file for system
#	acpype + manual top editing

#	step 1
#	edit empty box

$gmx editconf -f $insy/str/UNK_GMX.gro -o $insy/str/step01_vacbox.gro -c -d 1.1 -bt dodecahedron

#	step 2
#	solvate

$gmx solvate -cp $insy/str/step01_vacbox.gro -cs $insy/str/ffamber_tip3p.gro -o $insy/str/step02_solv.gro -p $insy/top/step00_syst.top

#	NO GENERATE IONS

#gmx grompp
#gmx genion

#	trajconv
#	a - generate tpr with grompp
#	b - transform compacting atoms
#	c - transform compacting molecules

$gmx grompp -f $run/par/step03_ions.mdp -c $insy/str/step02_solv.gro -p $insy/top/step00_syst.top -o $insy/step02_solv_wrap.tpr -po $insy/step02_solv_wrap.mdp -pp $insy/top/step02_solv_wrap.top

echo 2 0 | $gmx trjconv -s $insy/step02_solv_wrap.tpr -f $insy/str/step02_solv.gro -o $insy/str/step02_solv_wrap1.gro -pbc atom -ur compact -center

echo 2 0 | $gmx trjconv -s $insy/step02_solv_wrap.tpr -f $insy/str/step02_solv_wrap1.gro -o $insy/str/step02_solv_wrap2.gro -pbc mol -ur compact -center 

#   Will write gro: Coordinate file in Gromos-87 format
#   Reading file 1_init_syst/step02_solv_wrap.tpr, VERSION 2021-MODIFIED (single precision)
#   Reading file 1_init_syst/step02_solv_wrap.tpr, VERSION 2021-MODIFIED (single precision)
#   Select group for centering
#   Group     0 (         System) has 19911 elements
#   Group     1 (          Other) has    90 elements
#   Group     2 (            UNK) has    90 elements
#   Group     3 (          Water) has 19821 elements
#   Group     4 (            SOL) has 19821 elements
#   Group     5 (      non-Water) has    90 elements
#   Select a group: 2
#   Selected 2: 'UNK'
#   Select group for output
#   Group     0 (         System) has 19911 elements
#   Group     1 (          Other) has    90 elements
#   Group     2 (            UNK) has    90 elements
#   Group     3 (          Water) has 19821 elements
#   Group     4 (            SOL) has 19821 elements
#   Group     5 (      non-Water) has    90 elements
#   Select a group: 0
#   Selected 0: 'System'
#   Reading frames from gro file 'UNK in water', 19911 atoms.
#   Reading frame       0 time    0.000   
#   Precision of 1_init_syst/str/step02_solv_wrap1.gro is 0.001 (nm)
#   Last frame          0 time    0.000   
#   
