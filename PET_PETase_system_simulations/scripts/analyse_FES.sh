#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# from belfast tutorial
# https://www.plumed.org/doc-v2.9/user-doc/html/belfast-6.html
# templates/plumed/belfast-6/Exercise_3/analyze_FES.sh

# ./analyze_FES.sh NFES min_a max_a min_b max_b KBT
# ../../scripts/04i_analyze_FES.sh  120   0.3   0.5   0.6   1.0   2.5
# 1 HILL = 500 steps * 0.002 ps = 1 ps
# nfeps * stride = 120 * 5000 = 600000 ps = 600 ns
# nfes=$(ls sd0_*.dat | wc -l) minA=0.3 maxA=0.5 minB=0.6 maxB=1.0 kbt=2.5 fes="sd0" stride=5000
# ../../scripts/04i_analyze_FES.sh $nfes $minA $maxA $minB $maxB $kbt $fes $stride > dF.dat
#
# minA=0.3 maxA=0.5 minB=0.6 maxB=1.0
# ../../scripts/04i_analyze_FES.sh $minA $maxA $minB $maxB > dF.dat

if [[ ! -d "dF" ]]; then
#    echo make dF dir
    mkdir dF
#else
#    echo dF exists
fi

# number of free-energy profiles
nfes=$(echo $(ls sd0_*.dat | wc -l) - 1 | bc -l)
#echo $nfes
#nfes=$(( $1 -1 ))
# minimum of basin A
minA=$1
# maximum of basin A
maxA=$2
# minimum of basin B
minB=$3
# maximum of basin B
maxB=$4
# stride of HILLS
str=1000
# temperature in energy units
kbt=2.5
# name of fes file
fes='sd0'

for i in `seq 0 ${nfes}`
do
 # calculate free-energy of basin A
 A=`awk 'BEGIN{tot=0.0}{if($1!="#!" && $1>min && $1<max)tot+=exp(-$2/kbt)}END{print -kbt*log(tot)}' min=${minA} max=${maxA} kbt=${kbt} ${fes}_${i}.dat`
 # and basin B
 B=`awk 'BEGIN{tot=0.0}{if($1!="#!" && $1>min && $1<max)tot+=exp(-$2/kbt)}END{print -kbt*log(tot)}' min=${minB} max=${maxB} kbt=${kbt} ${fes}_${i}.dat`
 # calculate difference
 Delta=`echo "${A} - ${B}" | bc -l`
 time=`echo "${i} * ${str}" | bc -l`
 # print it
 #echo $i $Delta
 echo $time $Delta
done

