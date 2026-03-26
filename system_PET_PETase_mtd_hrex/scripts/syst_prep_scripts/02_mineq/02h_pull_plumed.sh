#!/usr/bin/env bash

#   DESCRIPTION
#   write plumed.dat to force the orbiting and pulling towards the binding position in xray coordinates from reference
#   from systs/$syt/02_mineq directory
#   ../../../scripts/02_mineq/02h_pull_plumed.sh
#   for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; echo $syst; ls; ../../../scripts/02_mineq/02h_pull_plumed.sh $syst; ls ; cd ../../../; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

# Get the protein ID from the command-line argument
prot=$1

# Define the path to your Python script or module
PYTHON_SCRIPT_PATH="../../../templates/prep/petase_references.py"

# triad = {pdbid : [ name, [ser, his, asp], pro, nterm, [s-s1], [s-s2], [met, tyr], [trp1, trp2] ] }

# Run Python script and capture multiple values
eval $(python3 - <<END
import sys
sys.path.append("../../../templates/prep")
import petase_references as ref

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

## Now you can use $SER, $HIS, $ASP in your script
#echo "Serine: $SER"
#echo "Histidine: $HIS"
#echo "Aspartic Acid: $ASP"

#gro=systs/$prot/01_sysprep/complex.gro
gro=../01_sysprep/complex.gro
ref=refcoord.pdb
ser="${SER}SER"
his="${HIS}HIS"
asp="${ASP}ASP"
met="${MET}MET"
#   tyr="${TYR}TYR"
ox2="${OX2}${RN2}"
trp="${TRP}TRP"
#   serOG=`awk -v ser=$ser '{if($2=="OG" && $1==ser)print $3}' $gro`
#   serOG=`awk -v ser=$ser '{if($2=="OG" && $1==ser)print $3}' $gro`        # cat ser 160 OG ser-OH 

protid=`grep -v UNK $gro | tail -2 | head -1 | awk '{print $3}'`            # last id protein
serCA=`awk -v ser=$ser '{if($2=="CA" && $1==ser)print $3}' $gro`            # cat ser 160 CA
coordSERca=`awk -v serCA=$serCA '{if($2==serCA) print $7","$8","$9}' $ref`  # cat ser 160 CA coord to restr
serOG=`awk -v ser=$ser '{if($2=="OG" && $1==ser)print $3}' $gro`            # cat ser 160 OG ser-OH 
metN=`awk -v met=$met '{if($2=="N" && $1==met)print $3}' $gro`              # oxyanion hole met N
#   tyrN=`awk -v tyr=$tyr '{if($2=="N" && $1==tyr)print $3}' $gro`              # oxyanion hole tyr N
ox2N=`awk -v ox2=$ox2 '{if($2=="N" && $1==ox2)print $3}' $gro`              # oxyanion hole tyr N
trpCD2=`awk -v trp=$trp '{if($2=="CD2" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
trpCE2=`awk -v trp=$trp '{if($2=="CE2" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
trpCE3=`awk -v trp=$trp '{if($2=="CE3" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
trpCZ2=`awk -v trp=$trp '{if($2=="CZ2" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
trpCZ3=`awk -v trp=$trp '{if($2=="CZ3" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
trpCH2=`awk -v trp=$trp '{if($2=="CH2" && $1==trp)print $3}' $gro`          # wobbling TRP 6ring
liga=`grep UNK $gro | head -1 | awk '{print $3}'`                           # first id ligand
ligb=`grep UNK $gro | tail -1 | awk '{print $3}'`                           # last id ligand
c17=`awk '{if($2=="C17" && $1 ~ /UNK/)print $3}' $gro`                      # lig C carbonyl extreme1
c19=`awk '{if($2=="C19" && $1 ~ /UNK/)print $3}' $gro`                      # lig C carbonyl central
c39=`awk '{if($2=="C39" && $1 ~ /UNK/)print $3}' $gro`                      # lig C carbonyl extreme2
o7=`awk '{if($2=="O7" && $1 ~ /UNK/)print $3}' $gro`                        # lig O carbonyl central
# adding rmsd to ref
refa=`head -1 $ref | awk '{print $2}'`                                      # first CA idx  coord
refb=`tail -1 $ref | awk '{print $2}'`                                      # last  CA idx  coord
c11=`awk '{if($2=="C11" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray ext
c12=`awk '{if($2=="C12" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray
c13=`awk '{if($2=="C13" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray
c14=`awk '{if($2=="C14" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray ext
c15=`awk '{if($2=="C15" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray
c16=`awk '{if($2=="C16" && $1 ~ /UNK/)print $3}' $gro`                      # lig C ring coord xray
o4=`awk '{if($2=="O4" && $1 ~ /UNK/)print $3}' $gro`                        # lig O carb coord xray
c7=`awk '{if($2=="O7" && $1 ~ /UNK/)print $3}' $gro`                        # lig O carb coord xray

# write pull.dat with moving restraint for the ligand
cat > pull.dat << EOF
UNITS LENGTH=A              # change all dist in Angstroms!!!

WHOLEMOLECULES ENTITY0=1-$ligb      #$protid ENTITY1=$liga-$ligb # prot0 lig1
MOLINFO STRUCTURE=eq.pdb

DISTANCE    LABEL=d0    ATOMS=$serOG,$c19                       # 131 SER OG vs UNK C19
DISTANCE    LABEL=d1    ATOMS=$c17,$c39                         # UNK C17 vs C39
COM         LABEL=C0    ATOMS=1-$protid                         # prot0
DISTANCE    LABEL=d2    ATOMS=$c19,C0                           # UNK C19 vs com
ANGLE       LABEL=a0    ATOMS=$serCA,C0,$c19                    # 131 SER CA vs com vs UNK C19
DISTANCE    LABEL=h0    ATOMS=$metN,$o7                         # 161 MET N vs O7
DISTANCE    LABEL=h1    ATOMS=$ox2N,$o7                         #  87 TYR N vs O7
DRMSD       LABEL=drms0 REFERENCE=refcoord.pdb  LOWER_CUTOFF=0.0 UPPER_CUTOFF=8.0 # CA prot and xray 

FIXEDATOM  LABEL=a1 AT=$coordSERca                      # dummy atoms coord at ser CA 
DISTANCE   LABEL=d3 ATOMS=a1,$serCA                     # dist dummy cat ser CA

MOVINGRESTRAINT ...

ARG=a0,d2,d0,h0,h1,drms0
STEP0=0        AT0=0,25,5,3,3,0    KAPPA0=0,0,0,0,0,0               # starting point
STEP1=2500     AT1=0,25,5,3,3,0    KAPPA1=5000,5000,0,0,0,0         # orbiting
STEP2=5000     AT2=0,25,5,3,3,0    KAPPA2=5000,5000,0,0,0,0         # stabilizing
STEP3=17500    AT3=0,25,5,3,3,0    KAPPA3=0,0,0,5000,5000,5000      # drms and hole pull to xray align

... MOVINGRESTRAINT

LOWER_WALLS ARG=d1 AT=23 KAPPA=250 EXP=2 EPS=1 OFFSET=0 LABEL=lwall     # prevents ligand to wrap
UPPER_WALLS ARG=d3 AT=2  KAPPA=500 EXP=2 EPS=1 OFFSET=0 LABEL=uwall     # prevents serine to extrude AS
# maybe restraints not upper wall for serine d3

PRINT    ARG=*    STRIDE=10    FILE=pull_colvar
EOF
