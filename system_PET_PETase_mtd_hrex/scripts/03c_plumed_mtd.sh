#!/usr/bin/env bash

#   DESCRIPTION
#   write plumed.dat to start production mtd with hrex from starting position on cluster 1 last frame on vmd clustring

source ~/.projects_startup.sh > /dev/null 2>&1

gmx=gmx_mpi

# Get the protein ID from the command-line argument
#prot=${1:-"6eqe"}
prot="6eqe"

# Define the path to your Python script or module
PYTHON_SCRIPT_PATH="templates/prot_prep/references_petase.py"

# triad = {pdbid : [ name, [ser, his, asp], pro, nterm, [s-s1], [s-s2], [met, tyr], [trp1, trp2] ] }

# Run Python script and capture multiple values
eval $(python3 - <<END
import sys
sys.path.append("templates/prot_prep")
import references_petase as ref

prot = '$prot'
ser = ref.triad[prot][1][0]
his = ref.triad[prot][1][1]
asp = ref.triad[prot][1][2]
met = ref.triad[prot][6][0]
#   tyr = ref.triad[prot][6][1][0]
ox2 = ref.triad[prot][6][1][0]  # muts for phe or tyr | oxyanion aa 2
rn2 = ref.triad[prot][6][1][1]  # muts for phe or tyr | ox aa 2 resname 
trp = ref.triad[prot][7][1]

# Print export statements for Bash
print(f"export SER={ser}")
print(f"export HIS={his}")
print(f"export ASP={asp}")
print(f"export MET={met}")
#   print(f"export TYR={tyr}")
print(f"export OX2={ox2}")
print(f"export RN2={rn2}")
print(f"export TRP={trp}")
END
)

gro='cluster.gro'
ser="${SER}SER"
his="${HIS}HIS"
asp="${ASP}ASP"
met="${MET}MET"
ox2="${OX2}${RN2}"
trp="${TRP}TRP"

protid=`awk '{if (!($1 ~ "UNK") && !($1 ~ "CL") && !($1 ~ "NA") && !($1 ~ "SOL")) print $3}' $gro | tail -2 | head -1`    # last id protein
serOG=` awk -v ser=$ser '{if($2=="OG"  && $1==ser)print $3}' $gro`                                                        # cat ser 160 OG ser-OH 
metN=`  awk -v met=$met '{if($2=="N"   && $1==met)print $3}' $gro`                                                        # oxyanion hole met N
ox2N=`  awk -v ox2=$ox2 '{if($2=="N"   && $1==ox2)print $3}' $gro`                                                        # oxyanion hole tyr N
hisNE2=`awk -v his=$his '{if($2=="NE2" && $1==his)print $3}' $gro`                                                        # cat his NE2 towards serOG

trpCD2=`awk -v trp=$trp '{if($2=="CD2" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring
trpCE2=`awk -v trp=$trp '{if($2=="CE2" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring
trpCE3=`awk -v trp=$trp '{if($2=="CE3" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring
trpCZ2=`awk -v trp=$trp '{if($2=="CZ2" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring
trpCZ3=`awk -v trp=$trp '{if($2=="CZ3" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring
trpCH2=`awk -v trp=$trp '{if($2=="CH2" && $1==trp)print $3}' $gro`                                                        # wobbling TRP 6ring

liga=`awk '{if ($1 ~ "UNK") print $3}' $gro | head -1`                                                                    # first id ligand
ligb=`awk '{if ($1 ~ "UNK") print $3}' $gro | tail -1`                                                                    # last id ligand

c17=`awk '{if($2=="C17" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C carbonyl extreme1
c19=`awk '{if($2=="C19" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C carbonyl central
c39=`awk '{if($2=="C39" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C carbonyl extreme2
o7=` awk '{if($2=="O7"  && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig O carbonyl central
c11=`awk '{if($2=="C11" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray ext
c12=`awk '{if($2=="C12" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c13=`awk '{if($2=="C13" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c14=`awk '{if($2=="C14" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray ext
c15=`awk '{if($2=="C15" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c16=`awk '{if($2=="C16" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
o4=` awk '{if($2=="O4"  && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig O carb coord xray
c7=` awk '{if($2=="O7"  && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig O carb coord xray

nrep=8
tmin=298
tmax=698

#heights="0.5,0.564646,0.637648,0.720091,0.813191,0.918329,1.03706,1.17114"
#HEIGHT=@replicas:$heights       # standard ~0.1-1.0*kBT KJ/mol | ~0.02-1.20 d, ~1.0-2.0 a -> TAU???

# for pair in "'h0,h1' cv_1" "'h0,s0' cv_2" "'h1,s0' cv_3"; do set -- $pair; cv=${1//\'/}; dir=$2; ./scripts/03c_plumed_multiCV.sh $cv $dir; done
# ./scripts/03c_plumed_mtd.sh "h0,h1" "hrex_mtd"

cv=${1:-"h0,h1"}
dir=${2:-"cv_0"}

echo $cv $dir

# write pull.dat with moving restraint for the ligand
cat > crys/$dir/crys.dat << EOF
#RESTART

WHOLEMOLECULES ENTITY0=1-$ligb      #$protid ENTITY1=$liga-$ligb # prot0 lig1

DISTANCE    LABEL=d0    ATOMS=$serOG,$c19                       # cat ${SER} SER OG vs UNK C19
DISTANCE    LABEL=d1    ATOMS=$c17,$c39                         # ext UNK C17 vs C39
DISTANCE    LABEL=h0    ATOMS=$metN,$o7                         # oxh ${MET} MET N vs O7
DISTANCE    LABEL=h1    ATOMS=$ox2N,$o7                         # oxh ${OX2} ${RN2} N vs O7
DISTANCE    LABEL=s0    ATOMS=$serOG,$hisNE2                    # cat ${HIS} HIS NE2 vs cat ${SER} SER OG
DISTANCE    LABEL=x0    ATOMS=$serOG,$metN                      # cat ${SER} SER OG vs oxh ${MET} MET N     # autohinibition
DISTANCE    LABEL=x1    ATOMS=$serOG,$ox2N                      # cat ${SER} SER OG vs oxh ${OX2} ${RN2} N     # autohinibition

#metad: METAD ...
#
#    ARG=$cv                         # h0,h1
#    SIGMA=0.05,0.05                 # 0.5*fluctuation ~ 1A
#    HEIGHT=0.5                      # standard ~0.1-1.0*kBT KJ/mol | ~0.02-1.20 d, ~1.0-2.0 a -> TAU???
#    PACE=500                        # ~100-500 steps relax system before next hill add # change from 400 to 500!!!
#    BIASFACTOR=15                   # barriers 20-30 KJ/mol need a bias factor of ~10-15 biol syst # change from 30 to 15!!!
#    TEMP=$tmin                      # well-tempered
#    GRID_MIN=-1.0,-1.0
#    GRID_MAX=2.0,2.0                # max min values cv, store hills in file, memory efficient ?
#
#...

UPPER_WALLS ARG=h0 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=h0_uwall        # 8A max distance from hole
UPPER_WALLS ARG=h1 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=h1_uwall        # 8A max distance from hole
UPPER_WALLS ARG=s0 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=s0_uwall        # 8A max distance from hole
UPPER_WALLS ARG=d0 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=d0_uwall        # 8A max distance from ser
#LOWER_WALLS ARG=x0 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=x0_uwall        # 8A max distance from hole
#LOWER_WALLS ARG=x1 AT=0.8 KAPPA=5000 EXP=2 EPS=1 OFFSET=0 LABEL=x1_uwall        # 8A max distance from hole

LOWER_WALLS ARG=d1 AT=4.0 KAPPA=2550 EXP=2 EPS=1 OFFSET=0 LABEL=d1_lwall        # crystalline stretch

PRINT ARG=* STRIDE=1000 FILE=colvar #print less
EOF

sed -e "s/LOWER_WALLS ARG=d1 AT=4.0 KAPPA=2550 EXP=2 EPS=1 OFFSET=0 LABEL=d1_lwall/LOWER_WALLS ARG=d1 AT=2.4 KAPPA=2550 EXP=2 EPS=1 OFFSET=0 LABEL=d1_lwall/" -e "s/crystalline/amorphous/" crys/$dir/crys.dat > amor/$dir/amor.dat

#mv $dir/crys.dat ../crys/$dir/crys.dat
#mv $dir/amor.dat ../amor/$dir/amor.dat
