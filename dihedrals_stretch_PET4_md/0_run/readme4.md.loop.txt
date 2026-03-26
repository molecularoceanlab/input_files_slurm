####################

	rotational analysis of ligand 4HEMT into water using 
	plumed lower wall restraints strategy
	28 mar 2022

####################


        --->>>          SECTION D       <<<---

###	MD production loop plumed restraint
###	7 abr 2022	
	
write a loop to create different MD directories.

same simulation of 100 ns with plumed lower wall

changing the max distance of the lower wall

from 37 A dicreasing 2 A each simulation		<<<--- ERROR!!! pymol A <-> plumed nm!!!!

9 hrs only achieved 10 % of job.

changed loop:

1. first quick create directories, plumed file and grompp.
2. mdrun and wrapping

separate slurm continuation





	--->>>		02 may 2022	<<<---

----------------------------
continuation is not completed on all loops (?)
relaunched with missing systems md1_07-19
----------------------------

        --->>>          05 may 2022     <<<---

----------------------------
reloop all the simulations using sbatch loop to parallelize 19 systems
###
for i in 0{6..9} {10..19}; do
cd $md/4_md/md_$i
sbatch job.$i.slurm
done
###
relaunched with missing systems md1_07-19
control progress using
> grep -E 'Writing checkpoint, step [0-9]'  md_*/*log
> tail tail md_*/COLVAR
----------------------------






!!! 	CHANGE PLUMED.DAT using 3.7 nm INSTEAD OF 37 A		!!!

bash does not handle floating point!!!
wayround

https://mathblog.com/floating-point-arithmetic-in-the-bourne-again-shell-bash/

        >>>     job4.slurm      <<<
                                                                #top
############################################################

lwall_a=`echo '39 / 10' | bc -l`		<<<--- declare variable as floating point

for i in 0{1..9} {10..19}			<- only for quick start mdrun
do

mkdir $md/4_md/md_$i

cd $md/4_md/md_$i

touch plumed_$i.dat				<- create folder, enter and create file

lwall_a=`echo $lwall_a - '0.2' | bc -l`		<<<--- reducing variable of floating units

echo -e "d1: DISTANCE ATOMS=21,53\n\		<<<--- WATCHOUT INDEXES!!!
t1: TORSION ATOMS=9-12\n\
t2: TORSION ATOMS=27,28,52,51\n\		<<<--- WATCHOUT DIHEDRAL VECTORS DIRECTION!!!
t3: TORSION ATOMS=37-40\n\n\
lwall: LOWER_WALLS ARG=d1 AT=$lwall_a KAPPA=150.0 EXP=2 EPS=1 OFFSET=0\n\
PRINT ARG=* FILE=COLVAR STRIDE=10000" >> plumed_$i.dat		<- stride resolution

$gmx grompp -f $run/par/step06_md1.mdp -c $md/3_eq_npt/step05_npt.gro -r $md/3_eq_npt/step05_npt.gro -p $md/3_eq_npt/step05_npt.top -t $md/3_eq_npt/step05_npt.cpt -o step06_md1_$i.tpr -pp step06_md1_$i.top -po step06_md1_$i.mdout.mdp		<- generate grompp .tpr

$gmx mdrun -v -s step06_md1_$i.tpr -deffnm step06_md1_$i -cpt 60 -plumed plumed_$i.dat -maxh 9 -nsteps 100
						<- start simulation with 100 steps to continue

[ wrap simulation outputs ]

############################################################
                                                                #bot
slurm dependency

       >>>     job6.slurm      <<<
                                                                #top
############################################################

for i in 0{1..9} {10..19}		<- simulation loop. probably need re-iterating
do

cd $md/4_md/md_$i

mpirun -np 96 $gmx mdrun -v -deffnm step06_md1_$i -cpi step06_md1_$i.cpt -cpt 60 -plumed plumed_$i.dat -maxh 9

#       wrap 2 steps

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.xtc -o step06_md1_$i.center.xtc -center -pbc mol -ur compact

echo 2 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.fit.xtc -fit rot+trans

#       dump first and last frames

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.start.pdb -dump 0

echo 0 | gmx trjconv -s step06_md1_$i.tpr -f step06_md1_$i.center.xtc -o step06_md1_$i.last.pdb -dump 100000

#       end of the loop

done

############################################################
                                                                #bot
