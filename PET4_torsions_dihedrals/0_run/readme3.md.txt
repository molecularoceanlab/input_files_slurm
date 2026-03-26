####################

	rotational analysis of ligand 4HEMT into water using 
	plumed lower wall restraints strategy
	28 mar 2022

####################


        --->>>          SECTION D       <<<---

###	MD production
###	05 abr 2022

run 100 ns production (to analyse plumed lower wall action)

plan to rerun simulation different kind to have different restraints on the lwall

50 M steps to 100 ns (at 2 fs dt for step)

writing frequency 100 ps

resolution constant of 1 frame = ???


USE SAME PRE-PROCESSING MIN.HEAT.EQ with strong plumed.dat lwall

DO NOT USE CENTER OF MASS NOR VERCTORS 
--->>> slows the calculation

use stride each 100 steps
plumed driver has resolution of trj.xtc
gmx plumed has max resolution, slow calculation.

calculate strong max tension to minimize structure, then slow restraint.

---> prepare 10 x simulations with new plumed input file
atoms 21,53 carbonylic carbons of extremities
37.8A distance

plumed 1st run 37 A lower wall

---> run 10 x simulations of 100 ns with lower wall -2 A each

	###	--->>>	simulation interrupted	<<<---	###

simulation didn't end after 9 h at 96 tasks
???
last step written 5.150 M steps -> 10.300 ns of 100 ns

plumed too expensive???

change to stride 10K???

output plumed is each 10 ps (50K steps)

sent new continuation of 9 hours with plumed.dat stride each 10 K

AFTER RESTARTING KEEPS STOPPING COMPLETED??????
TRY AND READ TPR!!!

ERROR IN INPUT FILE: -cpt xxx.cpt vs -cpi xxx.cpt

md.continuation requeued

        >>>     plumed.dat      <<<
                                                                #top
############################################################
d1: DISTANCE ATOMS=21,53
t1: TORSION ATOMS=9-12
t2: TORSION ATOMS=27,28,51,52
t3: TORSION ATOMS=37-40

lwall: LOWER_WALLS ARG=d1 AT=37 KAPPA=150.0 EXP=2 EPS=1 OFFSET=0
PRINT ARG=* FILE=COLVAR STRIDE=10000
############################################################
								#bot

        >>>     md1.mdp      <<<
                                                                #top
############################################################

title                   = MD simulation                       
; Run parameters
integrator              = md        ; leap-frog integrator
nsteps                  = 50000000  ; 2 * 5000000 = 10000 ps (10 ns) ;;; 100 ns
dt                      = 0.002     ; 2 fs
; Output control
nstenergy               = 50000      ; save energies every 10.0 ps
nstlog                  = 50000      ; update log file every 10.0 ps   ;;; 100 ps
nstxout-compressed      = 50000      ; save coordinates every 10.0 ps
; Bond parameters
continuation            = yes       ; continuing from NPT
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
pcoupl                  = Parrinello-Rahman             ; pressure coupling is on for NPT
pcoupltype              = isotropic                     ; uniform scaling of box vectors
tau_p                   = 2.0                           ; time constant, in ps
ref_p                   = 1.0                           ; reference pressure, in bar
compressibility         = 4.5e-5                        ; isothermal compressibility of water, bar^-1
; Periodic boundary conditions
pbc                     = xyz       ; 3-D PBC
; Dispersion correction is not used for proteins with the C36 additive FF
DispCorr                = no
; Velocity generation
gen_vel                 = no        ; continuing from NPT equilibration

############################################################
                                                                #bot
        >>>     job3.slurm      <<<
                                                                #top
############################################################

[ ... ]

#       step 6 MD production

cd $md/4_md

#       input parameters - continuation from npt

$gmx grompp -f $run/par/step06_md1.mdp -c $md/3_eq_npt/step05_npt.gro -r $md/3_eq_npt/step05_npt.gro -p $md/3_eq_npt/step05_npt.top -t $md/3_eq_npt/step05_npt.cpt -o step06_md1.tpr -pp step06_md1.top -po step06_md1.mdout.mdp # -maxwarn 100

#       simulation - continuation

mpirun -np 96 $gmx mdrun -v -s step06_md1.tpr -deffnm step06_md1 -cpt 60 -plumed $md/plumed.dat -maxh 9 # -nsteps 100

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.xtc -o step06_md1.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.start.pdb -dump 0

echo 0 | gmx trjconv -s step06_md1.tpr -f step06_md1.center.xtc -o step06_md1.last.pdb -dump 100000

############################################################
                                                                #bot

        >>>     job3.slurm      <<<
                                                                #top
############################################################
#       simulation - continuation

mpirun -np 96 $gmx mdrun -v -deffnm step06_md1 -cpi step06_md1.cpt -cpt 60 -plumed plumed.dat -maxh 9 # -nsteps 100
############################################################
                                                                #bot
