#!/usr/bin/env bash

# md parameters and mtd plumed file

source ~/.projects_startup.sh > /dev/null 2>&1

# edit md.mdp file

sed \
    -e "s/nstenergy               = 50000      ;/nstenergy               = 1000       ;/" \
    -e "s/nstlog                  = 50000      ;/nstlog                  = 1000       ;/" \
    -e "s/nstxout-compressed      = 50000      ;/nstxout-compressed      = 1000       ;/" \
    -e "s/tc-grps                 = Protein_HEM Water_and_ions    ;/tc-grps                 = UNK                 SOL            ;/" \
    templates/par_md/4_md1.mdp > par_md/3a_mtd.mdp

# set plumed file with standard mtd and lwall on ext-CO
gro='../../02_mineq/npt.gro' # ref file

c17_1=`awk '{if($2=="C17" && $1 ~ /UNK/)print $3}' $gro | head -1`   # lig C carbonyl extreme1
c19_1=`awk '{if($2=="C19" && $1 ~ /UNK/)print $3}' $gro | head -1`   # lig C carbonyl central
c39_1=`awk '{if($2=="C39" && $1 ~ /UNK/)print $3}' $gro | head -1`   # lig C carbonyl extreme2
o_7_1=`awk '{if($2=="O7"  && $1 ~ /UNK/)print $3}' $gro | head -1`   # lig O carbonyl central
c17_2=`awk '{if($2=="C17" && $1 ~ /UNK/)print $3}' $gro | tail -1`   # lig C carbonyl extreme1
c19_2=`awk '{if($2=="C19" && $1 ~ /UNK/)print $3}' $gro | tail -1`   # lig C carbonyl central
c39_2=`awk '{if($2=="C39" && $1 ~ /UNK/)print $3}' $gro | tail -1`   # lig C carbonyl extreme2
o_7_2=`awk '{if($2=="O7"  && $1 ~ /UNK/)print $3}' $gro | tail -1`   # lig O carbonyl central
liga_1=`grep "1UNK" $gro | head -1 | awk '{print $3}'`                    # first id ligand
ligb_1=`grep "1UNK" $gro | tail -1 | awk '{print $3}'`                    # last id ligand
liga_2=`grep "2UNK" $gro | head -1 | awk '{print $3}'`                    # first id ligand
ligb_2=`grep "2UNK" $gro | tail -1 | awk '{print $3}'`                    # last id ligand

# write pull.dat with moving restraint for the ligand
cat > par_md/crys.dat << EOF
#RESTART

WHOLEMOLECULES ENTITY0=$liga_1-$ligb_2 # UNK1 UNK2

COM         LABEL=c1    ATOMS=$liga_1-$ligb_1  	# UNK1 COM
COM         LABEL=c2    ATOMS=$liga_2-$ligb_2  	# UNK2 COM
DISTANCE    LABEL=d0	ATOMS=c1,c2				# COMs distance MTD CV
DISTANCE    LABEL=d1    ATOMS=$c17_1,$c39_1     # UNK1 C17 vs C39
DISTANCE    LABEL=d2    ATOMS=$c17_2,$c39_2     # UNK2 C17 vs C39

metad: METAD ...

    ARG=d0
    SIGMA=0.05	    # 0.5*fluctuation ~ 1A
    HEIGHT=0.5	    # standard ~0.1-1.0*kBT KJ/mol | ~0.02-1.20 d, ~1.0-2.0 a -> TAU??? | from rep0
    PACE=500        # ~100-500 steps relax system before next hill add
    BIASFACTOR=15   # barriers 20-30 KJ/mol need a bias factor of ~10-15 biol syst
    TEMP=300	    # well-tempered
    #GRID_MIN=0.1    # no IDEA
    #GRID_MAX=25.0   # max min values cv, store hills in file, memory efficient ?

...

UPPER_WALLS ARG=d0 AT=0.8 KAPPA=500   EXP=2 EPS=1 OFFSET=0 LABEL=uwall0             # limits grid max
LOWER_WALLS ARG=d1 AT=4.0 KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall1             # crystalline stretch
LOWER_WALLS ARG=d2 AT=4.0 KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall2             # crystalline stretch

PRINT ARG=* STRIDE=1000 FILE=colvar													#print less
EOF

sed \
	-e "s/AT=4.0 KAPPA=2250/AT=2.4 KAPPA=2250/" \
	-e "s/AT=4.0 KAPPA=2250/AT=2.4 KAPPA=2250/" \
	-e "s/crystalline/amorphous/" par_md/crys.dat > par_md/amor.dat

# prepare MD

$gmx grompp -f par_md/3a_mtd.mdp -c ../../02_mineq/npt.gro -p ../../02_mineq/npt.top -o mtd.tpr -pp mtd_pp.top -po mtd_out.mdp -maxwarn 1
rm *#*#*
