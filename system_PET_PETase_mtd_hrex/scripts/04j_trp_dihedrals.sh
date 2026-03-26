#!/usr/bin/env bash

start_time=$(date +%s)

# loads modules if on cesga

lig=${1:-"amor"}
dir=${2:-'.'}
xtc=${3:-"../hrex.fit.xtc"}
binning=${4:-"120 0.006"}

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

cat > wobbling.dat << EOF
RESTART

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

TORSION     LABEL=w1    ATOMS=$trpC,$trpCA,$trpCB,$trpCG        # wobbling TPR # from ref xhi1 # C or N ???
TORSION     LABEL=w2    ATOMS=$trpCA,$trpCB,$trpCG,$trpCD2      # wobbling TPR # from ref xhi2 # why CD2 and not CD1 ??
TORSION     LABEL=p0    ATOMS=$c12,$c11,$c10,$trpCD2            # pi-stack TPR # from ref

DISTANCE    LABEL=p1    ATOMS=$c12,$trpCD2                      # to avoid noise when ring2 flips on the other side. too far

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

PRINT ARG=* STRIDE=1 FILE=wobbling_cv #print less
EOF

cat << EOF >> wobbling.dat

### reweight histograms
as: REWEIGHT_BIAS ARG=metad.bias TEMP=298
EOF

nb=$(echo $binning | awk '{print $1}')
bw=$(echo $binning | awk '{print $2}')

declare -A cvs
declare -A cvs_max
declare -A cvs_min
cvs=( ["h0"]=0.7 ["h1"]=0.7 ["d0"]=1.0 ["s0"]=0.6 ["x0"]=0.5 ["x1"]=0.8 ["w1"]="3.15" ["w2"]="3.15" ["p0"]="3.15" )
cvs_max=( ["h0"]=0.7 ["h1"]=0.7 ["d0"]=1.0 ["s0"]=0.6 ["x0"]=0.5 ["x1"]=0.8 ["w1"]="3.15"  ["w2"]="3.15"  ["p0"]="3.15" )
cvs_min=( ["h0"]=0.2 ["h1"]=0.2 ["d0"]=0.2 ["s0"]=0.2 ["x0"]=0.2 ["x1"]=0.2 ["w1"]="-3.15" ["w2"]="-3.15" ["p0"]="-3.15" )
var=( ["w1"]="pi" ["w2"]="pi" ["p0"]="pi" )
# 1D terms
#for cv in h0 h1 s0 d0; do
#for cv_name in "${!cvs[@]}"; do
for cv_name in w1 w2 p0; do
        cv_max=${cvs_max[$cv_name]}  # Get min
        cv_min=${cvs_min[$cv_name]}  # Get max
        bw=$(awk -v max="$cv_max" -v min="$cv_min" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')

        if (( $(echo "$cv_max == 3.15" | bc -l) )); then
            cv_max='pi'
        fi
        if (( $(echo "$cv_min == -3.15" | bc -l) )); then
            cv_min='-pi'
        fi
        echo $cv_name $cv_max $cv_min

    cat << EOF >> wobbling.dat

h$cv_name: HISTOGRAM ARG=$cv_name LOGWEIGHTS=as BANDWIDTH=$bw   GRID_MIN=$cv_min GRID_MAX=$cv_max GRID_BIN=$nb
f$cv_name: CONVERT_TO_FES GRID=h$cv_name TEMP=298 MINTOZERO
DUMPGRID GRID=f$cv_name FILE=f$cv_name.dat
EOF
done

cv_name='p0'
cv_max=${cvs_max[$cv_name]}  # Get min
cv_min=${cvs_min[$cv_name]}  # Get max
bw=$(awk -v max="$cv_max" -v min="$cv_min" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')

if (( $(echo "$cv_max == 3.15" | bc -l) )); then
    cv_max='pi'
fi
if (( $(echo "$cv_min == -3.15" | bc -l) )); then
    cv_min='-pi'
fi
echo $cv_name if $cv_max $cv_min

cat << EOF >> wobbling.dat

UPDATE_IF ARG=p1 MORE_THAN=0.8
hp0if: HISTOGRAM ARG=p0 LOGWEIGHTS=as BANDWIDTH=$bw   GRID_MIN=$cv_min GRID_MAX=$cv_max GRID_BIN=$nb
fp0if: CONVERT_TO_FES GRID=hp0if TEMP=298 MINTOZERO
DUMPGRID GRID=fp0 FILE=fp0_if.dat
UPDATE_IF ARG=p1 END 
EOF

# 2D terms (unique pairs)
var1=(h0 h1 d0 s0 x0 x1 w1 w2 p0)
var2=( w1 w2 p0 )

#for ((i=0; i<${#vars[@]}; i++)); do
#    for ((j=i+1; j<${#vars[@]}; j++)); do
for v1 in w1 w2 p0; do
    for v2 in w1 w2 p0 d0 h0 h1 s0; do
        if [[ "$v1" != "$v2"  ]]; then
            cv_max1=${cvs_max[$v1]}  # Get min
            cv_min1=${cvs_min[$v1]}  # Get max
            bw1=$(awk -v max="$cv_max1" -v min="$cv_min1" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')
            cv_max2=${cvs_max[$v2]}  # Get min
            cv_min2=${cvs_min[$v2]}  # Get max
            bw2=$(awk -v max="$cv_max2" -v min="$cv_min2" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')

            echo $v1 $v2 $cv_min1 $cv_min2 $cv_min2 $cv_min2

            if (( $(echo "$cv_max1 == 3.15" | bc -l) )); then
                cv_max1='pi'
            fi
            if (( $(echo "$cv_min1 == -3.15" | bc -l) )); then
                cv_min1='-pi'
            fi
            if (( $(echo "$cv_max2 == 3.15" | bc -l) )); then
                cv_max2='pi'
            fi
            if (( $(echo "$cv_min2 == -3.15" | bc -l) )); then
                cv_min2='-pi'
            fi

            echo $v1 $v2 $cv_min1 $cv_min2 $cv_min2 $cv_min2

        cat << EOF >> wobbling.dat

h${v1}${v2}: HISTOGRAM ARG=${v1},${v2} LOGWEIGHTS=as BANDWIDTH=$bw1,$bw2 GRID_MIN=$cv_min1,$cv_min2 GRID_MAX=$cv_max1,$cv_max2 GRID_BIN=$nb,$nb
f${v1}${v2}: CONVERT_TO_FES GRID=h${v1}${v2} TEMP=298 MINTOZERO
DUMPGRID GRID=f${v1}${v2} FILE=f${v1}_${v2}.dat
EOF
        fi
    done
done

v1='p0'
v2='d0'
cv_max1=${cvs_max[$v1]}  # Get min
cv_min1=${cvs_min[$v1]}  # Get max
bw1=$(awk -v max="$cv_max1" -v min="$cv_min1" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')
cv_max2=${cvs_max[$v2]}  # Get min
cv_min2=${cvs_min[$v2]}  # Get max
bw2=$(awk -v max="$cv_max2" -v min="$cv_min2" -v nb="$nb" 'BEGIN { printf "%.5f", (max - min) / nb }')

if (( $(echo "$cv_max1 == 3.15" | bc -l) )); then
    cv_max1='pi'
fi
if (( $(echo "$cv_min1 == -3.15" | bc -l) )); then
    cv_min1='-pi'
fi
if (( $(echo "$cv_max2 == 3.15" | bc -l) )); then
    cv_max2='pi'
fi
if (( $(echo "$cv_min2 == -3.15" | bc -l) )); then
    cv_min2='-pi'
fi

echo $v1 $v2 $cv_min1 $cv_min2 $cv_min2 $cv_min2

cat << EOF >> wobbling.dat

UPDATE_IF ARG=p1 MORE_THAN=0.8
h${v1}if${v2}: HISTOGRAM ARG=${v1},${v2} LOGWEIGHTS=as BANDWIDTH=$bw1,$bw2 GRID_MIN=$cv_min1,$cv_min2 GRID_MAX=$cv_max1,$cv_max2 GRID_BIN=$nb,$nb
f${v1}if${v2}: CONVERT_TO_FES GRID=h${v1}if${v2} TEMP=298 MINTOZERO
DUMPGRID GRID=f${v1}if${v2} FILE=f${v1}_${v2}_if.dat
UPDATE_IF ARG=p1 END 
EOF

# execute if xtc set to value, if empty not execute # -n varible set -z variable empty. also use ! to contrary

if [[ -n "$xtc" ]]; then
    echo reweighting
#    plumed driver --plumed wobbling.dat --mf_xtc $xtc
fi

for file in wobbling_cv f??.dat f??_??.dat f??_??_??.dat HILLS; do
    if [[ -f "$file" ]]; then
        echo removing previous $file
        rm $file
    else echo reweighting $file
    fi
done

rm *bck.*

if ls *#*#* 1> /dev/null 2>&1; then
    rm *#*#*
fi

sleep 5

end_time=$(date +%s)

elapsed_time=$((end_time - start_time))

minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))

echo "END sumhills: ${minutes} m : ${seconds} s"

