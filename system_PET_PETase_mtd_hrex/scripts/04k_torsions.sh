#!/usr/bin/env bash

# loads modules if on cesga

lig=${1:-"amor"}
dir=${2:-'.'}
xtc=${3:-"../hrex.fit.xtc"}

scripts=$( dirname ${BASH_SOURCE[0]})

source ~/.projects_startup.sh > /dev/null 2>&1
source ./$scripts/get_index.sh "6eqe" "$dir/../03_production/cluster.gro" "$dir"

if [[ "$lig" == "amor" ]]; then
    wall=2.4
    state='amorphous'
elif [[ "$lig" == "crys" ]]; then
    wall=4.0
    state='crystalline'
fi

cat > torsions.dat << EOF
#RESTART

WHOLEMOLECULES ENTITY0=1-$ligb      #$protid ENTITY1=$liga-$ligb # prot0 lig1

DISTANCE    LABEL=d0    ATOMS=$serOG,$c19                       # cat ${SER} SER OG vs UNK C19
DISTANCE    LABEL=d1    ATOMS=$c17,$c39                         # ext UNK C17 vs C39
DISTANCE    LABEL=h0    ATOMS=$metN,$o7                         # oxh ${MET} MET N vs O7
DISTANCE    LABEL=h1    ATOMS=$ox2N,$o7                         # oxh ${OX2} ${RN2} N vs O7
DISTANCE    LABEL=s0    ATOMS=$serOG,$hisNE2                    # cat ${HIS} HIS NE2 vs cat ${SER} SER OG
DISTANCE    LABEL=x0    ATOMS=$serOG,$metN                      # cat ${SER} SER OG vs oxh ${MET} MET N     # autohinibition
DISTANCE    LABEL=x1    ATOMS=$serOG,$ox2N                      # cat ${SER} SER OG vs oxh ${OX2} ${RN2} N     # autohinibition

TORSION     LABEL=t1    ATOMS=$t1_id                            # torsion eg
TORSION     LABEL=t2    ATOMS=$t2_id                            # torsion eg
TORSION     LABEL=t3    ATOMS=$t3_id                            # torsion eg

metad: METAD ...

    ARG=h0,h1                         # h0,h1
    SIGMA=0.05,0.05                 # 0.5*fluctuation ~ 1A
    HEIGHT=0.0                      # standard ~0.1-1.0*kBT KJ/mol | ~0.02-1.20 d, ~1.0-2.0 a -> TAU???
    PACE=10000000                        # ~100-500 steps relax system before next hill add # change from 400 to 500!!!
    BIASFACTOR=15                   # barriers 20-30 KJ/mol need a bias factor of ~10-15 biol syst # change from 30 to 15!!!
    TEMP=298                      # well-tempered
    GRID_MIN=-1.0,-1.0
    GRID_MAX=2.0,2.0                # max min values cv, store hills in file, memory efficient ?

    FILE=HILLS
...

UPPER_WALLS ARG=h0 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=h0_uwall        # 6A max distance from hole
UPPER_WALLS ARG=h1 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=h1_uwall        # 6A max distance from hole
#UPPER_WALLS ARG=s0 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=s0_uwall        # 6A max distance from hole
#UPPER_WALLS ARG=d0 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=d0_uwall        # 6A max distance from ser
#LOWER_WALLS ARG=x0 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=x0_uwall        # 6A max distance from hole
#LOWER_WALLS ARG=x1 AT=0.6 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=x1_uwall        # 6A max distance from hole

LOWER_WALLS ARG=d1 AT=$wall KAPPA=2550 EXP=2 EPS=1 OFFSET=0 LABEL=d1_lwall        # $state stretch

PRINT ARG=* STRIDE=1 FILE=torsions_cv #print less
EOF

# execute if xtc set to value, if empty not execute # -n varible set -z variable empty. also use ! to contrary

if [[ -n "$xtc" ]]; then
    plumed driver --plumed torsions.dat --mf_xtc $xtc
fi
