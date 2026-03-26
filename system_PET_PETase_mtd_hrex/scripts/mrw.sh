#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# Find maximum value of bias to avoid numerical errors when calculating the un-biasing weights
#bmax=`awk 'BEGIN{max=0.}{if($1!="#!" && $12>max)max=$12}END{print max}' ../colvar.rw`
bmax=`awk 'BEGIN{max=0.}{if($1!="#!" && $8>max)max=$8}END{print max}' ../colvar.test1`

# Print phi values and un-biasing (un-normalized) weights
awk '{if($1!="#!") print $2,exp(($8-bmax)/kbt)}' kbt=2.494339 bmax=$bmax ../colvar.test1 > d0_bis.weight
awk '{if($1!="#!") print $2,$7,exp(($8-bmax)/kbt)}' kbt=2.494339 bmax=$bmax ../colvar.test1 > d0_dist.weight

# p 'crys/rw/manual_rw/d0.weight' u 1:(-2.49*(log($2))) # FREE ENERGY # 3D new plot
# sp 'd0_dist.weight' u 1:2:(-2.49*(log($3)))
# sp 'd0_dist.weight' u 1:2:(-2.49*(log($3))) w pm3d

# Arguments of do_block_fes.py
# - input file with CV value and weight for each frame of the trajectory: phi.weight
# - number of CVs: 1
# - CV range (min, max): (-3.141593, 3.141593)
# - # points in output free energy: 51
# - kBT (kJoule/mol): 2.494339
# - Block size: 1<=i<=1000 (every 10)
# 
#for i in `seq 1 10 1000`; do python3 ../../../scripts/do_block_fes.py d0.weight 1 0.3 2.0 100 2.494339 $i; done

#for i in `seq 1 10 1000`; do a=`awk '{tot+=$3}END{print tot/NR}' fes.$i.dat`; echo $i $a; done > error/err.blocks
