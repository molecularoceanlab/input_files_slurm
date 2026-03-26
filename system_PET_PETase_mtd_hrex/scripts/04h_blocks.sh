#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# ./04h_blocks.sh 'd0' 100 1 100000 1000 # 10000 blocks = 100 ns

kbt=2.494339
cv=${1:-'d0'}
bsize=${2:-100}
bmin=${3:-1}
bmax=${4:-1000}
bstp=${5:-10}
max=$(cat ${cv}.weight | grep -v FIELDS | sort -g -k1 | tail -1 | awk '{print $1}')
min=$(cat ${cv}.weight | grep -v FIELDS | sort -g -k1 | head -1 | awk '{print $1}')

echo -e "error bloc analysis on\n${cv}.weight 1 $max $min $bsize $kbt $bmin $bstp $bmax"
echo -e "run do_block_fes.py"

#for i in `seq 1 10 1000`; do
for i in `seq $bmin $bstp $bmax`; do
  kbt=2.494339
  #python3 do_block_fes.py d0.weight 1 0.868518 0.261704 100 2.494339 $i
  python3 do_block_fes.py ${cv}.weight 1 $max $min $bsize $kbt $i
done

echo -e "run error.block"

#for i in `seq 1 10 1000`; do 
for i in `seq $bmin $bstp $bmax`; do
    a=`awk '{tot+=$3}END{print tot/NR}' fes.$i.dat`
    echo $i $a; 
done > err.blocks
