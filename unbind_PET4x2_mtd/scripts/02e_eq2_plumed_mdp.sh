#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# edit eq.mdp extent infinite and continue md from pulling
# from 50000 (100 ps) to 50000000i (100 ns) too short for crys. extend infinite to -1
#-e "s/nsteps                  = 50000     ;/nsteps                  = -1        ;/"
#-e "s/nsteps                  = 5000000   ;/nsteps                  = -1        ;/"

sed \
    -e "s/nsteps                  = 5000000   ;/nsteps                  = -1        ;/" \
    -e "s/continuation            = no        ; starting from NVT/continuation            = yes       ; starting from pull/" \
    -e "s/gen_vel                 = yes       ; velocity generation on starting from NPT/gen_vel                 = no        ; velocity generation starting from pull/" \
    -e "/gen_temp/d" \
    -e "/gen_seed/d" \
    par_md/2c_npt.mdp > par_md/2d_npt_stretch.mdp

# set plumed file with standard mtd and lwall on ext-CO
gro='../02_mineq/npt.gro' # ref file

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

# write mtd.dat with moving restraint for the ligand
cat > crys/eq2_crys.dat << EOF
#RESTART
WHOLEMOLECULES ENTITY0=$liga_1-$ligb_2 # UNK1 UNK2

COM         LABEL=c1    ATOMS=$liga_1-$ligb_1   #NOPBC   # UNK1 COM
COM         LABEL=c2    ATOMS=$liga_2-$ligb_2   #NOPBC   # UNK2 COM
FIXEDATOM   LABEL=gc    AT=$x,$y,$z                     # geometrical center of the box
DISTANCE    LABEL=d0    ATOMS=c1,c2             #NOPBC   # COMs distance MTD CV
DISTANCE    LABEL=d1    ATOMS=$c17_1,$c39_1     #NOPBC   # UNK1 C17 vs C39
DISTANCE    LABEL=d2    ATOMS=$c17_2,$c39_2     #NOPBC   # UNK2 C17 vs C39
DISTANCE    LABEL=d3    ATOMS=gc,c1             #NOPBC   # UNK1 COM and geo centre
DISTANCE    LABEL=d4    ATOMS=gc,c2             #NOPBC   # UNK2 COM and geo centre

#metad: METAD ...
#
#    ARG=d0
#    SIGMA=0.05      # 0.5*fluctuation ~ 1A
#    HEIGHT=0.5      # standard ~0.1-1.0*kBT KJ/mol | ~0.02-1.20 d, ~1.0-2.0 a -> TAU??? | from rep0
#    PACE=500        # ~100-500 steps relax system before next hill add
#    BIASFACTOR=15   # barriers 20-30 KJ/mol need a bias factor of ~10-15 biol syst
#    TEMP=300        # well-tempered
#
#...

#   UPPER_WALLS ARG=d0 AT=1.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall0             # limits grid max
UPPER_WALLS ARG=d3 AT=0.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall3             # limits grid max
#   UPPER_WALLS ARG=d4 AT=1.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall4             # limits grid max
LOWER_WALLS ARG=d1 AT=4.0 KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall1             # crystalline stretch
LOWER_WALLS ARG=d2 AT=4.0 KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall2             # crystalline stretch

PRINT ARG=* STRIDE=500    FILE=colvar.eq2                                               #print less
EOF

sed \
    -e "s/AT=4.0 KAPPA=2250/AT=2.4 KAPPA=2250/" \
    -e "s/AT=4.0 KAPPA=2250/AT=2.4 KAPPA=2250/" \
    -e "s/crystalline/amorphous/" crys/eq2_crys.dat > amor/eq2_amor.dat


