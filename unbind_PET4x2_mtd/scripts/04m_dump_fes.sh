#!/usr/bin/env bash

# loads modules if on cesga

lig=${1:-"amor"}
dir=${2:-'.'}
#xtc=${3:-"../mtd.fit.xtc"}

scripts=$( dirname ${BASH_SOURCE[0]})

source ~/.projects_startup.sh > /dev/null 2>&1
#source ./$scripts/get_index.sh "6eqe" "$dir/../03_production/cluster.gro" "$dir"
source ./$scripts/get_index.sh "None" "$dir/../02_mineq/nvt.gro" "$dir"

if [[ "$lig" == "amor" ]]; then
    wall=2.4
    state='amorphous'
    minima=(0.06 0.20 0.40 0.55 1.55 2.10 2.50)
elif [[ "$lig" == "crys" ]]; then
    wall=4.0
    state='crystalline'
    minima=(0.40 0.65 1.00 1.35 1.70 2.10 2.40)
fi

# set plumed file with standard mtd and lwall on ext-CO
gro='../../../02_mineq/npt.gro' # ref file

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

# get indeces for eg atoms for tors
for i in {1..3}; do
  for j in {1..4}; do
    eval name=\$t${i}_a${j}
    eval t${i}_a${j}_index_2=$(awk -v a="$name" '$2==a && $1 ~ /2UNK/ {print $3; exit}' "$gro")
  done
done

t1_id_2=$(echo -e "$t1_a1_index_2,$t1_a2_index_2,$t1_a3_index_2,$t1_a4_index_2")
t2_id_2=$(echo -e "$t2_a1_index_2,$t2_a2_index_2,$t2_a3_index_2,$t2_a4_index_2")
t3_id_2=$(echo -e "$t3_a1_index_2,$t3_a2_index_2,$t3_a3_index_2,$t3_a4_index_2")

# box half size to calculate the geometrical center. no com as too dynamic
x=$(tail -1 $gro | awk '{print $1/2}')
y=$(tail -1 $gro | awk '{print $2/2}')
z=$(tail -1 $gro | awk '{print $3/2}')

echo "DUMPMASSCHARGE FILE=mcfile" > dump.dat


cat > fes_min.dat << EOF
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

TORSION     LABEL=t1    ATOMS=$t1_id                            # torsion eg
TORSION     LABEL=t2    ATOMS=$t2_id                            # torsion eg
TORSION     LABEL=t3    ATOMS=$t3_id                            # torsion eg

TORSION     LABEL=t4    ATOMS=$t1_id_2                          # torsion eg
TORSION     LABEL=t5    ATOMS=$t2_id_2                          # torsion eg
TORSION     LABEL=t6    ATOMS=$t3_id_2                          # torsion eg

#   UPPER_WALLS ARG=d0 AT=1.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall0             # limits grid max
UPPER_WALLS ARG=d3 AT=0.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall3             # limits grid max
#   UPPER_WALLS ARG=d4 AT=1.0 KAPPA=1000  EXP=2 EPS=1 OFFSET=0 LABEL=uwall4             # limits grid max
LOWER_WALLS ARG=d1 AT=$wall KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall1             # $state stretch
LOWER_WALLS ARG=d2 AT=$wall KAPPA=2250  EXP=2 EPS=1 OFFSET=0 LABEL=lwall2             # $state stretch

#PRINT ARG=* STRIDE=1      FILE=fes_min_cv                                                 #print less

EOF

# Loop over each minimum
for min in "${minima[@]}"; do
    # Calculate window limits
    more_than=$(echo "$min - 0.05" | bc)
    less_than=$(echo "$min + 0.05" | bc)

    # Create unique .gro file for this window
    echo "UPDATE_IF ARG=d0 MORE_THAN=${more_than} LESS_THAN=${less_than}" >> fes_min.dat
    echo "DUMPATOMS ATOMS=$liga_1-$ligb_2 FILE=PETs_${min}.xtc" >> fes_min.dat
    echo "PRINT ARG=* FILE=cv_${min}" >> fes_min.dat
    echo "UPDATE_IF ARG=d0 END" >> fes_min.dat
    echo "" >> fes_min.dat
done

# execute if xtc set to value, if empty not execute # -n varible set -z variable empty. also use ! to contrary

# dry run using topology file to extract the masses
#gmx_mpi mdrun -s ../mtd.tpr -nsteps 1 -plumed dump.dat

#if [[ -n "$xtc" ]]; then
#    plumed driver --plumed fes_min.dat --mf_xtc $xtc --mc mcfile
#fi
