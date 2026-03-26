#!/usr/bin/env bash

start_time=$(date +%s)

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# lig=amor i=1
# ../scripts/04f_reweight.sh $lig $i
# for lig in amor crys; do for i in 1 2 3; do echo $lig $i; (cd $lig/cv_${i}; ../../scripts/04f_reweight.sh $lig $i; cd ..) &; done; done; wait
# i=1; for lig in amor crys; do echo $lig $i; (cd $lig/cv_${i}; ../../scripts/04f_reweight.sh $lig $i "mtd.fit.short_20.xtc"; cd ..) &; done;  wait

# for lig in amor crys; do echo $lig ; (cd $lig/hrex_mtd/r0; ../../../scripts/04f_reweight.sh $lig "hrex.xtc"; cd ../../..) &; done;  wait

lig=${1:-'amor'}
traj=${2:-'hrex.fit.xtc'}
binning=${3:-"120 0.006"} # (0.9-0.2)/120 # 120 nbins

echo "reweight on $lig binning $binning"

sed -e "s/#RESTART/RESTART/" \
    -e "s/MOLINFO STRUCTURE=..\/..\/cluster.pdb/#MOLINFO STRUCTURE=..\/..\/..\/03_production\/cluster.pdb/" \
    -e 's/HEIGHT=[^ ]\+/HEIGHT=0.0/' \
    -e 's/PACE=[0-9.]\+/PACE=10000000/g' \
    -e '/^\.\.\.$/i \\tFILE=HILLS' \
    -e 's/STRIDE=1000/STRIDE=1/g' \
    -e 's/FILE=colvar/FILE=colvar.reweight/g' $lig.dat > mtd_reweight.dat

cat << EOF >> mtd_reweight.dat

### reweight histograms
as: REWEIGHT_BIAS ARG=metad.bias TEMP=298
EOF

# bin_width = (grid_max - grid_min)/nbins | bin_width ~ band_width to control smoothing
# Your bandwidth (0.01) is larger than the bin width (0.003). This isn't necessarily an error, but it means each bin will be smoothed over several neighboring bins, reducing resolution.
# bin width ~ bandwidth
# Case                              GRID_BIN    Bin Width   BANDWIDTH
# Fine-grained bins                 400         0.003       0.003
# Balanced                          200         0.006       0.006
# Matching bin width to bandwidth   120         0.01        0.01
# If you want sharp details, lower BANDWIDTH.
# If you want smooth curves, keep BANDWIDTH > bin width
#h$cv: HISTOGRAM ARG=$cv LOGWEIGHTS=as BANDWIDTH=0.01 GRID_MIN=0.0 GRID_MAX=1.2 GRID_BIN=400
#f$cv: CONVERT_TO_FES GRID=h$cv TEMP=298 MINTOZERO
#DUMPGRID GRID=f$cv FILE=f$cv.dat
# grid max h0,h1 ~ 0.8
# grid max d0    ~ 0.9 (0.85-0.93)
# grid max s0    ~ 0.6

nb=$(echo $binning | awk '{print $1}')
bw=$(echo $binning | awk '{print $2}')

declare -A cvs
cvs=( ["h0"]=0.7 ["h1"]=0.7 ["d0"]=1.0 ["s0"]=0.6 ["x0"]=0.5 ["x1"]=0.8 )

# 1D terms
#for cv in h0 h1 s0 d0; do
for cv_name in "${!cvs[@]}"; do
        cv_max=${cvs[$cv_name]}  # Get column number
        bw=$(awk -v max="$cv_max" -v nb="$nb" 'BEGIN { printf "%.5f", (max - 0.2) / nb }')
    echo $cv_name $cv_max
    cat << EOF >> mtd_reweight.dat

h$cv_name: HISTOGRAM ARG=$cv_name LOGWEIGHTS=as BANDWIDTH=$bw   GRID_MIN=0.2 GRID_MAX=$cv_max GRID_BIN=$nb
f$cv_name: CONVERT_TO_FES GRID=h$cv_name TEMP=298 MINTOZERO
DUMPGRID GRID=f$cv_name FILE=f$cv_name.dat
EOF
done

# 2D terms (unique pairs)
vars=(h0 h1 d0 s0 x0 x1)

for ((i=0; i<${#vars[@]}; i++)); do
    for ((j=i+1; j<${#vars[@]}; j++)); do
        cv1=${vars[i]}
        cv2=${vars[j]}
        max1=${cvs[$cv1]}
        max2=${cvs[$cv2]}
        bw1=$(awk -v max="$max1" -v nb="$nb" 'BEGIN { printf "%.5f", (max - 0.2) / nb }')
        bw2=$(awk -v max="$max2" -v nb="$nb" 'BEGIN { printf "%.5f", (max - 0.2) / nb }')

        cat << EOF >> mtd_reweight.dat

h${cv1}${cv2}: HISTOGRAM ARG=${cv1},${cv2} LOGWEIGHTS=as BANDWIDTH=$bw1,$bw2 GRID_MIN=0.2,0.2 GRID_MAX=$max1,$max2 GRID_BIN=$nb,$nb
f${cv1}_${cv2}: CONVERT_TO_FES GRID=h${cv1}${cv2} TEMP=298 MINTOZERO
DUMPGRID GRID=f${cv1}_${cv2} FILE=f${cv1}_${cv2}.dat
EOF
    done
done

for file in colvar.reweight fh0.dat fh1.dat fs0.dat fd0.dat fx0.dat fx1.dat; do
    if [[ -f "$file" ]]; then
        echo removing previous $file
        rm $file
    else echo reweighting $file
    fi
done

plumed driver --plumed mtd_reweight.dat --mf_xtc $traj

# calculate reweight for each variable manually
#../../scripts/manual_rw.sh

mv f*.dat fes/
mv *weight weights

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

