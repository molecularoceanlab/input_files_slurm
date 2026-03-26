####################

	rotational analysis of ligand 4HEMT into water using 
	plumed lower wall restraints strategy
	28 mar 2022

####################

https://www.plumed.org/doc-v2.8/user-doc/html/_l_o_w_e_r__w_a_l_l_s.html

	--->>>		SECTION A	<<<---

### 	ligand preparation
	by FC
	
	marvin sketch
	maestro
	acpype
	gromacs

ligand has topology (.itp and .top) and structure (.gro)

        >>>     ligand.top      <<<
                                                                top
############################################################

; UNK_GMX.top created by acpype (Rev: 0) on Wed Oct 27 12:30:37 2021

[ defaults ]
; nbfunc        comb-rule       gen-pairs       fudgeLJ fudgeQQ
1               2               yes             0.5     0.8333

; Include UNK_GMX.itp topology
#include "UNK_GMX.itp"                                          <<<--- correct path!!!

[ system ]
 UNK

[ molecules ]
; Compound        nmols
 UNK              1


############################################################
                                                                bot

it does not have ff included or water ff.
adjust ligand topology.

        >>>     NEW.ligand.top      <<<
                                                                top
############################################################

; UNK_GMX.top created by acpype (Rev: 0) on Wed Oct 27 12:30:37 2021

; force field???                                <<-- added from protein top
; Include forcefield parameters                 <<-- error second defaults directives
#include "amber99sb-ildn.ff/forcefield.itp"

;   [ defaults ]
;   ; nbfunc        comb-rule       gen-pairs       fudgeLJ fudgeQQ
;   1               2               yes             0.5     0.8333

; Include UNK_GMX.itp topology
#include "../itp/UNK_GMX.itp"

; include solvent topology                      <<-- added from protein
; Include water topology
#include "amber99sb-ildn.ff/tip3p.itp"

#ifdef POSRES_WATER
; Position restraint for each water oxygen
[ position_restraints ]
;  i funct       fcx        fcy        fcz
   1    1       1000       1000       1000
#endif

; Include topology for ions
#include "amber99sb-ildn.ff/ions.itp"

[ system ]
UNK in water

[ molecules ]
; Compound        nmols
 UNK              1
SOL              6607

############################################################
                                                                bot

------>>	after correcting the topology we can start the system preparation
		looking for the correction of the error of missing mol type
		for SOL 

###	gmx preparation initial system

generate box of water to contain ligand. no ions no additional concentration.
standard molecules preparation (like proteins) go through pdb2gmx and automatically the force field and the water type is added to the topology

ligand goes through acpype preparation of topology and the .top file has
missing informations for the solvent moleculetype.

generating the box and solvate will add water molecules to the .gro structure
file but the following step will have the error of

SOL (resname of water) no moleculetype found. the reason it has no molecule
type in the topology


--->>> MANUALLY ADD FF; WATER AND IONS FF TO THE TOPOLOGY
--->>> MANUALLY HIDE LIG FF??? VERIFY

sistem preparation script

        >>>     job1.sh      <<<

                                                                top
############################################################

#!/bin/bash

cd ..

#       cesga modules
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

#       step0
#       generate structure and topology file for system
#       acpype + manual top editing

#       step 1
#       edit empty box

$gmx editconf -f $insy/str/UNK_GMX.gro -o $insy/str/step01_vacbox.gro -c -d 1.1 -bt dodecahedron

#       step 2
#       solvate

$gmx solvate -cp $insy/str/step01_vacbox.gro -cs $insy/str/ffamber_tip3p.gro -o $insy/str/step02_solv.gro -p $insy/top/step00_syst.top

#       NO GENERATE IONS

#gmx grompp
#gmx genion

#       trajconv
#       a - generate tpr with grompp
#       b - transform compacting atoms
#       c - transform compacting molecules

$gmx grompp -f $run/par/step03_ions.mdp -c $insy/str/step02_solv.gro -p $insy/top/step00_syst.top -o $insy/step02_solv_wrap.tpr -po $insy/step02_solv_wrap.mdp -pp $insy/top/step02_solv_wrap.top

echo 2 0 | $gmx trjconv -s $insy/step02_solv_wrap.tpr -f $insy/str/step02_solv.gro -o $insy/str/step02_solv_wrap1.gro -pbc atom -ur compact -center

echo 2 0 | $gmx trjconv -s $insy/step02_solv_wrap.tpr -f $insy/str/step02_solv_wrap1.gro -o $insy/str/step02_solv_wrap2.gro -pbc mol -ur compact -center


############################################################
                                                                bot

trjconv options

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


        --->>>          SECTION B       <<<---


###	plumed input file

	>>>	plumed.dat	<<<

from plumed tutorial
/mnt/lustre/scratch/home/csic/eyg/sdp/7_HEMTx4_lwall

								top
############################################################

d1: DISTANCE ATOMS=3,5 
d2: DISTANCE ATOMS=2,4 
uwall: UPPER_WALLS ARG=d1,d2 AT=1.0,1.5 KAPPA=150.0,150.0 EXP=2,2 EPS=1,1 OFFSET=0,0 
lwall: LOWER_WALLS ARG=d1,d2 AT=0.0,1.0 KAPPA=150.0,150.0 EXP=2,2 EPS=1,1 OFFSET=0,0 
PRINT ARG=uwall.bias,lwall.bias 

############################################################
								bot
only lower wall
atoms?

4 units of HEMT
first and last carbonilic carbon of the chain C17 (ID 21) and C39 (ID 53)

use geometric center of unit

https://www.plumed.org/doc-v2.6/user-doc/html/lugano-1.html

usind centroid to set the wall limit
https://www.plumed.org/doc-v2.6/user-doc/html/_c_e_n_t_e_r.html
and torsion to set angle
https://www.plumed.org/doc-v2.6/user-doc/html/_t_o_r_s_i_o_n.html

use center of mass of calculated first and last units of 4HEMT to set the lower wall potential
use torsion calculation of angles on plane

first unit heavy atoms:
C1-C8,C17-C18,O1-O2,O5-O6
1-10,21-24

last unit heavy atorm:
C29-C36,C39-C40,O11-O12,O15-O16
39-48,53-56

distance from first and last (8th) C carbonilic 21-53=37.8A
distance from second and 7th C carbonilic 41-7=27.1A		<<<--- set first lower wall

torsion dihedral between central etylenic group (51-52-28-27)

t: TORSION ATOMS=1,2,3,4 
# this is an alternative, equivalent, definition:
# t: TORSION VECTOR1=2,1 AXIS=2,3 VECTOR2=3,4
PRINT ARG=t FILE=COLVAR 


--->>> plumed.dat:
                                                                top
############################################################

d1: DISTANCE ATOMS=21,53					<<<--- distance of the lwall? max?
t1: TORSION ATOMS=51-52-28-27
center1: CENTER ATOMS=1-10,21-24
center4: CENTER ATOMS=39-48,53-56
lwall: LOWER_WALLS ARG=d1 AT=0.0 KAPPA=150.0 EXP=2 EPS=1 OFFSET=0
PRINT ARG=lwall.bias FILE=COLVAR

############################################################
                                                                bot

general factor as the tutorial is too generic and no further help is found

ERROR PLUMED INPUT: atoms selection changed (intervals and csv)

--->>> plumed.dat:
                                                                top
############################################################

d1: DISTANCE ATOMS=21,53
t1: TORSION ATOMS=27-28,51-52
center1: CENTER ATOMS=1-10,21-24
center4: CENTER ATOMS=39-48,53-56
lwall: LOWER_WALLS ARG=d1 AT=0.0 KAPPA=150.0 EXP=2 EPS=1 OFFSET=0
PRINT ARG=lwall.bias FILE=COLVAR

############################################################
                                                                bot

