#!/usr/bin/env bash

# mkdir block.cv
# cp cv.weight block.cv/
# delete FIELDS line at the top of the cv.weight
# cd block.cv
# run script.sh block analysis

# - Block size: 1<=i<=1000 (every 10)
# 

cv=${1:-'d0'}
scripts='../../../scripts'
kbt=2.494339
bsize=100
max=$(cat ${cv}.weight | grep -v FIELDS | sort -g -k1 | tail -1 | awk '{print $1}')
min=$(cat ${cv}.weight | grep -v FIELDS | sort -g -k1 | head -1 | awk '{print $1}')
# for i in `seq 1 10 1000`; do
# seq change 1 100 10000
# seq change 1 1000 100000
bmin=1
bmax=1000
bstp=10

echo -e "error bloc analysis on\n${cv}.weight 1 $max $min $bsize $kbt"

echo -e "run do_block_fes.py"

#for i in `seq 1 10 1000`; do
for i in `seq $bmin $bstp $bmax`; do
    echo "$bmin $bstp $bmax"
    #python3 do_block_fes.py d0.weight 1 0.868518 0.261704 100 2.494339 $i
    echo -e "python3 ${scripts}/do_block_fes.py ${cv}.weight 1 $max $min $bsize $kbt $i"
    python3 ${scripts}/do_block_fes.py ${cv}.weight 1 $max $min $bsize $kbt $i
done

echo -e "run error.block"

#for i in `seq 1 10 1000`; do 
for i in `seq $bmin $bstp $bmax`; do
    a=`awk '{tot+=$3}END{print tot/NR}' fes.$i.dat`; echo $i $a;
done > err.blocks

