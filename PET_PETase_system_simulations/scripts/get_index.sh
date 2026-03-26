#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# Get the protein ID from the command-line argument
prot=${1:-"6eqe"}
gro=${2:-"cluster.gro"}
dir=${3:-'.'}

# Define the path to your Python script or module
PYTHON_SCRIPT_PATH="$dir/templates/prot_prep/references_petase.py"

# triad = {pdbid : [ name, [ser, his, asp], pro, nterm, [s-s1], [s-s2], [met, tyr], [trp1, trp2] ] }

# Run Python script and capture multiple values
eval $(python3 - <<END
import sys
sys.path.append("$dir/templates/prot_prep")
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

for i, eg in enumerate(ref.MHET4["egs"]):
    t = ref.MHET4["egs"][eg]
    print(f'export t{i+1}="{t}"')
    for a, name in enumerate(ref.MHET4["egs"][eg]):
        print(f"export t{i+1}_a{a+1}={name}")
END
)

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

# dihedral angle wobbling of Trp185
# ATOMS=@chi1:185
# DIHEDRAL LABEL=chi1 ATOMS=CA,CB,CG,CD1
# grep -A10 "185 TRP" your.pdb
# from PET model to TPR ring
# 3 atoms from one and 4rt from the other

trpC=`  awk -v trp=$trp '{if($2=="C"   && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
trpN=`  awk -v trp=$trp '{if($2=="N"   && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
trpCA=` awk -v trp=$trp '{if($2=="CA"  && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
trpCB=` awk -v trp=$trp '{if($2=="CB"  && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble

trpCG=` awk -v trp=$trp '{if($2=="CG"  && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
trpNE1=`awk -v trp=$trp '{if($2=="NE1" && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
trpCD1=`awk -v trp=$trp '{if($2=="CD1" && $1==trp)print $3}' $gro`                                                        # wobbling TRP wobble
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
c10=`awk '{if($2=="C10" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray ext
c11=`awk '{if($2=="C11" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray ext
c12=`awk '{if($2=="C12" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c13=`awk '{if($2=="C13" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c14=`awk '{if($2=="C14" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray ext
c15=`awk '{if($2=="C15" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
c16=`awk '{if($2=="C16" && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig C ring coord xray
o4=` awk '{if($2=="O4"  && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig O carb coord xray
c7=` awk '{if($2=="O7"  && $1 ~ /UNK/)print $3}' $gro`                                                                    # lig O carb coord xray

# get indeces for eg atoms for tors
for i in {1..3}; do
  for j in {1..4}; do
    eval name=\$t${i}_a${j}
    eval t${i}_a${j}_index=$(awk -v a="$name" '$2==a && $1 ~ /UNK/ {print $3; exit}' "$gro")
  done
done

t1_id=$(echo -e "$t1_a1_index,$t1_a2_index,$t1_a3_index,$t1_a4_index")
t2_id=$(echo -e "$t2_a1_index,$t2_a2_index,$t2_a3_index,$t2_a4_index")
t3_id=$(echo -e "$t3_a1_index,$t3_a2_index,$t3_a3_index,$t3_a4_index")
