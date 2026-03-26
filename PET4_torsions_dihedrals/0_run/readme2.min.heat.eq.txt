####################

	rotational analysis of ligand 4HEMT into water using 
	plumed lower wall restraints strategy
	28 mar 2022

####################


        --->>>          SECTION C       <<<---

as only ligand with lower wall restraint in no-ionic water system
sun all preparation steps with plumed input file.

###     MIN
###	04 abr 2022

normal input run with lwall restrant

https://manual.gromacs.org/documentation/2019-current/user-guide/run-time-errors.html#can-not-do-conjugate-gradients-with-constraints

"Can not do Conjugate Gradients with constraints¶
This means you can’t do energy minimization with the conjugate gradient algorithm if your topology has constraints defined."

NO PLUMED FOR THE MIN???

test

$gmx grompp -f $run/par/step03_min1.mdp -c $insy/str/step02_solv.gro -r $insy/str/step02_solv.gro -p $insy/top/step00_syst.top -o step03_min1.tpr -pp step03_min1.top -po step03_min1.mdout.mdp # -maxwarn 100

$gmx mdrun -v -s step03_min1.tpr -deffnm step03_min1 -cpt 60 -nsteps 100 # -plumed $md/plumed.dat

        >>>     min.mdp      <<<
                                                                #top
############################################################

; LINES STARTING WITH ';' ARE COMMENTS
title         = Minimization    ; Title of run

; Parameters describing what to do, when to stop and what to save
integrator    = steep           ; Algorithm (steep = steepest descent minimization)
emtol         = 1000.0          ; Stop minimization when the maximum force < 10.0 kJ/mol
emstep        = 0.01            ; Energy step size
nsteps        = 50000           ; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist       = 1               ; Frequency to update the neighbor list and long range forces
cutoff-scheme = Verlet
ns_type       = grid            ; Method to determine neighbor list (simple, grid)
rlist         = 1.2             ; Cut-off for making neighbor list (short range forces)
coulombtype   = PME             ; Treatment of long range electrostatic interactions
rcoulomb      = 1.2             ; long range electrostatic cut-off
vdwtype       = cutoff
vdw-modifier  = force-switch
rvdw-switch   = 1.0
rvdw          = 1.2             ; long range Van der Waals cut-off
pbc           = xyz             ; Periodic Boundary Conditions
DispCorr      = no

############################################################
								#bot
###	HEAT NVT
###	04 abr 2022

temperature coupling in two groups with simulating annealing. maybe non necessary.
disabling posres as intro plumed.dat lower wall restraints

reading groups from trjconv output

$gmx grompp -f $run/par/step04_nvt.mdp -c $md/1_min/step03_min1.gro -r $md/1_min/step03_min1.gro -p $md/1_min/step03_min1.top -o step04_nvt.tpr  -pp step04_nvt.top -po step04_nvt.mdout.mdp # -maxwarn 100

$gmx mdrun -v -s step04_nvt.tpr -deffnm step04_nvt -cpt 60 -nsteps 100 -plumed $md/plumed.dat


PLUMED ERROR:
------------------------------------------------------------------
wn exception:
(exception type: N4PLMD14ExceptionErrorE)

+++ PLUMED error
+++ at Action.cpp:243, function void PLMD::Action::error(const string&) const
+++ message follows +++
ERROR in input to action TORSION with label t1 : it was not possible to
interpret atom name 51-52-28-27
------------------------------------------------------------------

--->>> names!!!

plumed atoms selection. order numbers??? NO interval instead of comma separated values (1,3,6-9).
	-> 51-52-28-27 is an unreadable interval!
	-> 27-28,51-52 is a readable list of 2 intervals!!!

https://www.plumed.org/doc-v2.8/user-doc/html/_group.html

       >>>     nvt.mdp      <<<
                                                                #top
############################################################
title                    = heating NVT equilibration, temperature coupling groups and annealing
;define                  = ;;;; -DPOSRES
;include                 = ;;;; -I../../top/itp      ; include itp folder to find posres.itp

; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 250000     ; 2 * 50000 = 100 ps ;;; NEW 500 ps ;;;
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 50000   ; save energies every 1.0 ps ;;; NEW each 100 ps ;;;
nstlog                  = 50000   ; update log file every 1.0 ps
nstxout-compressed      = 50000   ; save coordinates every 1.0 ps ;;; TOO MUCH ;;;
; Bond parameters
continuation            = no        ; first dynamics run
constraint_algorithm    = lincs     ; holonomic constraints
constraints             = h-bonds   ; bonds to H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2       ; short-range electrostatic cutoff (in nm)
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = V-rescale                     ; modified Berendsen thermostat
tc-grps                 = UNK SOL                       ; two coupling groups - more accurate
tau_t                   = 0.1   0.1                     ; time constant, in ps
ref_t                   = 300   300                     ; reference temperature, one for each group, in K
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Annealing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
annealing                 = single single
annealing_npoints         = 6 6
annealing_time            = 0   100  150  200  300  400 0   100  150  200  300  400
annealing_temp            = 100 200 200 250 250 300 100 200 200 250 250 300
; Pressure coupling
pcoupl                  = no        ; no pressure coupling in NVT
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no
; Velocity generation
gen_vel                 = yes       ; assign velocities from Maxwell distribution
gen_temp                = 300       ; temperature for Maxwell distribution
gen_seed                = -1        ; generate a random seed

############################################################
                                                                #bot

NEW PLUMED INPUT
--->>> plumed.dat:
                                                                top
############################################################

center1: CENTER ATOMS=1-10,21-24 MASS
center2: CENTER ATOMS=39-48,53-56 MASS

d1: DISTANCE ATOMS=center1,center2
t1: TORSION VECTOR1=27-28 AXIS=28,52 VECTOR2=51-52
t2: TORSION VECTOR1=9-10 AXIS=10-11 VECTOR2=11-12
t3: TORSION VECTOR1=37-38 AXIS=38-39 VECTOR2=39-40

lwall: LOWER_WALLS ARG=d1 AT=27.1 KAPPA=150.0 EXP=2 EPS=1 OFFSET=0
PRINT ARG=t1,t2,t3,lwall.bias FILE=COLVAR

############################################################
                                                                bot
###	EQ NPT
###	05 abr 2022

       >>>     nvt.mdp      <<<
                                                                #top
############################################################
title                   = NPT equilibration, pressure coupling groups
define                  = ;;; -DPOSRES ; position restrain the protein and ligand

; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 50000     ; 2 * 50000 = 100 ps
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 500       ; save energies every 1.0 ps
nstlog                  = 500       ; update log file every 1.0 ps
nstxout-compressed      = 500       ; save coordinates every 1.0 ps
; Bond parameters
continuation            = yes       ; continuing from NVT
constraint_algorithm    = lincs     ; holonomic constraints
constraints             = h-bonds   ; bonds to H are constrained
lincs_iter              = 1         ; accuracy of LINCS
lincs_order             = 4         ; also related to accuracy
; Neighbor searching and vdW
cutoff-scheme           = Verlet
ns_type                 = grid      ; search neighboring grid cells
nstlist                 = 20        ; largely irrelevant with Verlet
rlist                   = 1.2
vdwtype                 = cutoff
vdw-modifier            = force-switch
rvdw-switch             = 1.0
rvdw                    = 1.2       ; short-range van der Waals cutoff (in nm)
; Electrostatics
coulombtype             = PME       ; Particle Mesh Ewald for long-range electrostatics
rcoulomb                = 1.2
pme_order               = 4         ; cubic interpolation
fourierspacing          = 0.16      ; grid spacing for FFT
; Temperature coupling
tcoupl                  = V-rescale                     ; modified Berendsen thermostat
tc-grps                 = UNK SOL                       ; two coupling groups - more accurate
tau_t                   = 0.1   0.1                     ; time constant, in ps
ref_t                   = 300   300                     ; reference temperature, one for each group, in K
; Pressure coupling
pcoupl                  = Berendsen                     ; pressure coupling is on for NPT
pcoupltype              = isotropic                     ; uniform scaling of box vectors
tau_p                   = 2.0                           ; time constant, in ps
ref_p                   = 1.0                           ; reference pressure, in bar
compressibility         = 4.5e-5                        ; isothermal compressibility of water, bar^-1
refcoord_scaling        = com
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no
; Velocity generation
gen_vel                 = no        ; velocity generation off after NVT
############################################################
                                                                #bot
$gmx grompp -f $run/par/step05_npt.mdp -c $md/2_heat_nvt/step04_nvt.gro -r $md/2_heat_nvt/step04_nvt.gro -p $md/2_heat_nvt/step04_nvt.top -t $md/2_heat_nvt/step04_nvt.cpt -o step05_npt.tpr -pp step05_npt.top -po step05_npt.mdout.mdp # -maxwarn 100

#mpirun -np 96
$gmx mdrun -v -s step05_npt.tpr -deffnm step05_npt -cpt 60 -nsteps 100 -plumed $md/plumed.dat

try min heat eq with plumed lwall

MIN WORKS WITH PLUME LWALL

NOTE 1 [file /mnt/lustre/scratch/home/csic/eyg/sdp/7_HEMTx4_lwall/0_run/par/step03_min1.mdp]:
  With Verlet lists the optimal nstlist is >= 10, with GPUs >= 20. Note
  that with the Verlet scheme, nstlist has no effect on the accuracy of
  your simulation.

Step=  100, Dmax= 1.7e-02 nm, Epot= -2.82559e+05 Fmax= 1.44750e+04, atom= 53
Energy minimization reached the maximum number of steps before the forces
reached the requested precision Fmax < 1000.

gmx energy -f xxx.edr -o xxx.xvg

  1  Bond             2  Angle            3  Proper-Dih.      4  Ryckaert-Bell.
  5  LJ-14            6  Coulomb-14       7  LJ-(SR)          8  Coulomb-(SR)  
  9  Coul.-recip.    10  Potential       11  Kinetic-En.     12  Total-Energy  
 13  Conserved-En.   14  Temperature     15  Pressure        16  Constr.-rmsd  
 17  Box-X           18  Box-Y           19  Box-Z           20  Volume        
 21  Density         22  pV              23  Enthalpy        24  Vir-XX        
 25  Vir-XY          26  Vir-XZ          27  Vir-YX          28  Vir-YY        
 29  Vir-YZ          30  Vir-ZX          31  Vir-ZY          32  Vir-ZZ        
 33  Pres-XX         34  Pres-XY         35  Pres-XZ         36  Pres-YX       
 37  Pres-YY         38  Pres-YZ         39  Pres-ZX         40  Pres-ZY       
 41  Pres-ZZ         42  #Surf*SurfTen   43  T-UNK           44  T-SOL         
 45  Lamb-UNK        46  Lamb-SOL      

###	WRAPPING
###	05 abr 2022

if concat needed use

gmx trjcat -f step08*_md*.xtc -o step08_md.all.xtc

center traj (2 steps)

echo 1 0 | gmx trjconv -s ../tpr/step08a_md1.tpr -f step08_md.all.xtc -o step08_md.center.xtc -center -pbc mol -ur compact

fit traj

echo 4 0 | gmx trjconv -s ../tpr/step08a_md1.tpr -f step08_md.center.xtc -o step08_md.fit.xtc -fit rot+trans

dump first structure

echo 0 | gmx trjconv -s ../tpr/step08a_md1.tpr -f step08_md.center.xtc -o step08_start.pdb -dump 0

dump last structure?

echo 0 | gmx trjconv -s ../tpr/step08a_md1.tpr -f step08_md.center.xtc -o step08_start.pdb -dump -1

        >>>     job2.slurm      <<<
                                                                #top
############################################################
#!/bin/bash

#SBATCH -t 0:10:00
#SBATCH --job-name=p7_3-5_min.heat.eq
#SBATCH --output=%J_p7_3-5_min.heat.eq.out
#SBATCH --error=%J_p7_3-5_min.heat.eq.err

#SBATCH -n 96 # number of tasks.
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p thinnodes,cola-corta # partitions with exclusive nodes recomended for MPI jobs

#       cesga modules
module load cesga/2020
module load gcc/system openmpi/4.0.5 gromacs/2021-PLUMED-2.7.1

cd $md/1_min

#       step 3  MIN

#       run parameter input

$gmx grompp -f $run/par/step03_min1.mdp -c $insy/str/step02_solv.gro -r $insy/str/step02_solv.gro -p $insy/top/step00_syst.top -o step03_min1.tpr -pp step03_min1.top -po step03_min1.mdout.mdp # -maxwarn 100

#       simulation

mpirun -np 96 $gmx mdrun -v -s step03_min1.tpr -deffnm step03_min1 -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#       quick analysis

echo 10 0 | $gmx energy -f step03_min1.edr -o step03_min1.xvg

cd ../2_heat_nvt

#       step 4  HEAT NVT

#       run input parameter

$gmx grompp -f $run/par/step04_nvt.mdp -c $md/1_min/step03_min1.gro -r $md/1_min/step03_min1.gro -p $md/1_min/step03_min1.top -o step04_nvt.tpr -pp step04_nvt.top -po step04_nvt.mdout.mdp # -maxwarn 100

#       simulation

mpirun -np 96 $gmx mdrun -v -s step04_nvt.tpr -deffnm step04_nvt -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#       quick analysis

echo 14 0 | $gmx energy -f step04_nvt.edr -o step04_nvt.xvg

cd ../3_eq_npt

#       step 5  EQ NPT

#       run input parameters - continuation!!!

$gmx grompp -f $run/par/step05_npt.mdp -c $md/2_heat_nvt/step04_nvt.gro -r $md/2_heat_nvt/step04_nvt.gro -p $md/2_heat_nvt/step04_nvt.top -t $md/2_heat_nvt/step04_nvt.cpt -o step05_npt.tpr -pp step05_npt.top -po step05_npt.mdout.mdp # -maxwarn 100

#       simulation - contiuation!!!

mpirun -np 96 $gmx mdrun -v -s step05_npt.tpr -deffnm step05_npt -cpt 60 -plumed $md/plumed.dat # -nsteps 100

#       quick analysis

echo 15 20 21 | $gmx energy -f step05_npt.edr -o step05_npt.xvg

#       return to main

cd $path

############################################################
								#bot

interruption for TIMEOUT (10 min 96 tasks mpi) plumed is slowing down

restart with 30 min from heating

###	WRAPPING

#	1_MIN

echo 2 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.trr -o step03_min1.center.xtc -center -pbc mol -ur compact

Select group for centering
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 2
Selected 2: 'UNK'
Select group for output
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 0
Selected 0: 'System'
trr version: GMX_trn_file (single precision)
Reading frame       0 time  148.000   
Setting output precision to 0.001 (nm)
Last frame          0 time  148.000   

---------------------------------

echo 2 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.fit.xtc -fit rot+trans

Select group for least squares fit
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 2
Selected 2: 'UNK'
Select group for output
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 3
Selected 3: 'Water'
Reading frame       0 time  148.000   
Precision of step03_min1.center.xtc is 0.001 (nm)
Using output precision of 0.001 (nm)
Last frame          0 time  148.000   

-------------------------------------------------

echo 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.start.pdb -dump 0

Select group for output
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 0
Selected 0: 'System'
Reading frame       0 time  148.000   
Precision of step03_min1.center.xtc is 0.001 (nm)
Last frame          0 time  148.000   
Reading frame       0 time  148.000   
Dumping frame at t= 148 ps
Last frame          0 time  148.000   


using FIT trajectory to dump the pdb rises error

Fatal error:
Index[19821] 19822 is larger than the number of atoms in the
trajectory file (19821). There is a mismatch in the contents
of your -f, -s and/or -n files.

----------------------------------------------------------------------------

#	dump first and last frame

echo 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.start.pdb -dump 0

echo 0 | gmx trjconv -s step03_min1.tpr -f step03_min1.center.xtc -o step03_min1.last.pdb -dump -1

Select group for output
Group     0 (         System) has 19911 elements
Group     1 (          Other) has    90 elements
Group     2 (            UNK) has    90 elements
Group     3 (          Water) has 19821 elements
Group     4 (            SOL) has 19821 elements
Group     5 (      non-Water) has    90 elements
Select a group: 0
Selected 0: 'System'
Reading frame       0 time  148.000   
Precision of step03_min1.center.xtc is 0.001 (nm)
Last frame          0 time  148.000   
Reading frame       0 time  148.000   
Dumping frame at t= 148 ps
Last frame          0 time  148.000   

### same for nvt and npt
