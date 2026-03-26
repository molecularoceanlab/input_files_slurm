#!/usr/bin/env bash

# md parameters and mtd plumed file

source ~/.projects_startup.sh > /dev/null 2>&1

# edit pull.mdp file performance around 300 ns / day on HREX eq

sed \
    -e "s/nsteps                  = 20000      ;/nsteps                  = 50000000        ;/" \
    -e "s/tc-grps                 = Protein_UNK Water_and_ions    ;/tc-grps                 = UNK         SOL               ;/" templates/par_md/5_ligpull.mdp > par_md/4_ligpull.mdp

# set plumed file with standard mtd and lwall on ext-CO
gro='npt.gro' # ref file

c17_1=`awk '{if($2=="C17" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl extreme1
c39_1=`awk '{if($2=="C39" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl extreme2
c19_1=`awk '{if($2=="C19" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl central
o_7_1=`awk '{if($2=="O7"  && $1 ~ /1UNK/)print $3}' $gro`   # lig O carbonyl central
c17_2=`awk '{if($2=="C17" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl extreme1
c39_2=`awk '{if($2=="C39" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl extreme2
c19_2=`awk '{if($2=="C19" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl central
o_7_2=`awk '{if($2=="O7"  && $1 ~ /2UNK/)print $3}' $gro`   # lig O carbonyl central
liga_1=`grep "1UNK" $gro | head -1 | awk '{print $3}'`		# first id ligand
ligb_1=`grep "1UNK" $gro | tail -1 | awk '{print $3}'`		# last id ligand
liga_2=`grep "2UNK" $gro | head -1 | awk '{print $3}'`		# first id ligand
ligb_2=`grep "2UNK" $gro | tail -1 | awk '{print $3}'`		# last id ligand

# box half size to calculate the geometrical center. no com as too dynamic
x=$(tail -1 $gro | awk '{print $1/2}')
y=$(tail -1 $gro | awk '{print $2/2}')
z=$(tail -1 $gro | awk '{print $3/2}')

# write pull.dat with moving restraint for the ligand
cat > par_md/pull_crys.dat << EOF
#RESTART
WHOLEMOLECULES ENTITY0=$liga_1-$ligb_2 # UNK1 UNK2

COM         LABEL=c1    ATOMS=$liga_1-$ligb_1	NOPBC   # UNK1 COM
COM         LABEL=c2    ATOMS=$liga_2-$ligb_2	NOPBC   # UNK2 COM
FIXEDATOM	LABEL=gc	AT=$x,$y,$z			 	        # geometrical center of the box
DISTANCE    LABEL=d0    ATOMS=c1,c2          	NOPBC   # COMs distance MTD CV
DISTANCE    LABEL=d1    ATOMS=$c17_1,$c39_1  	NOPBC   # UNK1 C17 vs C39
DISTANCE    LABEL=d2    ATOMS=$c17_2,$c39_2  	NOPBC   # UNK2 C17 vs C39
DISTANCE    LABEL=d3    ATOMS=gc,c1			  	NOPBC   # UNK1 COM and geo centre
DISTANCE    LABEL=d4    ATOMS=gc,c2			  	NOPBC   # UNK2 COM and geo centre

MOVINGRESTRAINT ...

ARG=d0,d1,d2,d3,d4

STEP0=0        AT0=1.0,4.0,4.0,0.5,0.5    KAPPA0=0,0,0,0,0                   # starting point
STEP1=25000    AT1=1.0,4.0,4.0,0.5,0.5    KAPPA1=100,0,0,100,100             # pulling towards center and each other (pulling reducing PBC)
STEP2=50000    AT2=1.0,4.0,4.0,0.5,0.5    KAPPA2=500,0,0,500,500             # stabilizing
STEP3=175000   AT3=1.0,4.0,4.0,0.5,0.5    KAPPA3=500,100,100,500,500         # start stretching
STEP4=250000   AT4=1.0,4.0,4.0,0.5,0.5    KAPPA4=100,100,100,100,100         # reduce force restraints to equilibrate pressure or clushes
STEP5=500000   AT5=1.0,4.0,4.0,0.5,0.5    KAPPA5=500,100,100,500,500         # stabilizing
STEP6=1500000  AT6=1.0,4.0,4.0,0.5,0.5    KAPPA6=0,100,100,100,100           # stop pulling keep restraints to the center

... MOVINGRESTRAINT

#   UPPER_WALLS ARG=d3,d4	AT=2.0,2.0	KAPPA=100,100	 LABEL=uwall3,uwall4
#   UPPER_WALLS ARG=d0,d3,d4	AT=1.0,2.0,2.0	KAPPA=100,100,100	 LABEL=uwall0,uwall3,uwall4 	#EXP=2,2,2 EPS=1,1,1 OFFSET=0,0,0  # 2mols com link, walls on the box to prevent pbc
#   LOWER_WALLS ARG=d1,d2		AT=4.0,4.0		KAPPA=1000,1000		 LABEL=lwall1,lwall2	        #EXP=2,2   EPS=1,1   OFFSET=0,0    # UNK1 UNK2 crystalline stretch prevents ligand to wrap

PRINT ARG=* STRIDE=10 FILE=colvar                                                 #print less
EOF

sed \
	-e "s/AT=4.0,4.0/AT=2.4,2.4/" \
    -e "s/=0.5,4.0,4.0/=0.5,2.4,2.4/" \
    -e "s/crystalline/amorphous/" par_md/pull_crys.dat > par_md/pull_amor.dat

# prepare pull

#for lig in "a300" "c300"; do
#
#	if [[ -d systs/02_mineq/pull_${lig} ]]; then echo "directory pull_${lig} exists"; else mkdir systs/02_mineq/pull_${lig}; fi
#    cd systs/02_mineq/pull_${lig}
#    $gmx grompp -f ../../../par_md/4_ligpull.mdp -c ../npt.gro -p ../npt.top -o pull.tpr -pp pull_pp.top -po pull_out.mdp -maxwarn 1
#    rm *#*#*
#    cd ../../../
#
#done

cd amor
$gmx grompp -f ../par_md/4_ligpull.mdp -c ../npt.gro -p ../npt.top -o pull.tpr -pp pull_pp.top -po pull_out.mdp -maxwarn 1
cp pull.tpr pull_pp.top pull_out.mdp ../crys/
cd ..
