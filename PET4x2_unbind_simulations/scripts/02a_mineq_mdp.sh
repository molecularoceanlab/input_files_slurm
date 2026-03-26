#!/usr/bin/env bash

# mdp preparation for min and eq

source ~/.projects_startup.sh > /dev/null 2>&1

# use standard min.mdp for minimization
ln -s templates/par_md/1_min.mdp par_md/2a_min.mdp
# update standard nvt.mdp npt.mdp for heating and equilibrium
# nvt.mdp
sed -e "s/define                  =/;define                  =/" \
    -e "s/tc-grps                 = Protein Non-Protein   ;/tc-grps                 = UNK         SOL       ;/" \
    templates/par_md/2_heat1.mdp > par_md/2b_nvt.mdp
# npt.mdp
sed -e "s/define                  =/;define                  =/" \
    -e "s/nsteps                  = 50000     ;/nsteps                  = 5000000   ;/" \
    -e "s/tc-grps                 = Protein_HEM Water_and_ions    ;/tc-grps                 = UNK         SOL               ;/" \
    templates/par_md/3_eq1.npt.mdp > par_md/2c_npt.mdp
# npt_stretch.mdp
sed -e "s/define                  =/;define                  =/" \
    -e "s/nsteps                  = 50000     ;/nsteps                  = 50000000  ;/" \
    -e "s/tc-grps                 = Protein_HEM Water_and_ions    ;/tc-grps                 = UNK         SOL               ;/" \
    templates/par_md/3_eq1.npt.mdp > par_md/2d_npt_stretch.mdp

# set plumed file with standard mtd and lwall on ext-CO
gro='../01_sysprep/solv.gro' # ref file

c17_1=`awk '{if($2=="C17" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl extreme1
c39_1=`awk '{if($2=="C39" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl extreme2
c19_1=`awk '{if($2=="C19" && $1 ~ /1UNK/)print $3}' $gro`   # lig C carbonyl central
o_7_1=`awk '{if($2=="O7"  && $1 ~ /1UNK/)print $3}' $gro`   # lig O carbonyl central
c17_2=`awk '{if($2=="C17" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl extreme1
c39_2=`awk '{if($2=="C39" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl extreme2
c19_2=`awk '{if($2=="C19" && $1 ~ /2UNK/)print $3}' $gro`   # lig C carbonyl central
o_7_2=`awk '{if($2=="O7"  && $1 ~ /2UNK/)print $3}' $gro`   # lig O carbonyl central
liga_1=`grep "1UNK" $gro | head -1 | awk '{print $3}'`      # first id ligand
ligb_1=`grep "1UNK" $gro | tail -1 | awk '{print $3}'`      # last id ligand
liga_2=`grep "2UNK" $gro | head -1 | awk '{print $3}'`      # first id ligand
ligb_2=`grep "2UNK" $gro | tail -1 | awk '{print $3}'`      # last id ligand

# box half size to calculate the geometrical center. no com as too dynamic
x=$(tail -1 $gro | awk '{print $1/2}')
y=$(tail -1 $gro | awk '{print $2/2}')
z=$(tail -1 $gro | awk '{print $3/2}')

# write stretch.dat with moving restraint for the ligand
cat > par_md/stretch.dat << EOF
#RESTART
WHOLEMOLECULES ENTITY0=$liga_1-$ligb_2 # UNK1 UNK2

COM         LABEL=c1    ATOMS=$liga_1-$ligb_1   NOPBC   # UNK1 COM
COM         LABEL=c2    ATOMS=$liga_2-$ligb_2   NOPBC   # UNK2 COM
FIXEDATOM   LABEL=gc    AT=$x,$y,$z                     # geometrical center of the box
DISTANCE    LABEL=d0    ATOMS=c1,c2             NOPBC   # COMs distance MTD CV
DISTANCE    LABEL=d1    ATOMS=$c17_1,$c39_1     NOPBC   # UNK1 C17 vs C39
DISTANCE    LABEL=d2    ATOMS=$c17_2,$c39_2     NOPBC   # UNK2 C17 vs C39
DISTANCE    LABEL=d3    ATOMS=gc,c1             NOPBC   # UNK1 COM and geo centre 
DISTANCE    LABEL=d4    ATOMS=gc,c2             NOPBC   # UNK2 COM and geo centre

MOVINGRESTRAINT ...

ARG=d1,d2

STEP0=0        AT0=4.0,4.0                KAPPA0=0,0                         # starting point
STEP1=25000    AT0=4.0,4.0                KAPPA0=100,100                     # stretch

... MOVINGRESTRAINT

PRINT ARG=* STRIDE=1 FILE=colvar                                                 #print less
EOF

