#!/usr/bin/env bash

# PLUMED REWEIGHT

lig=${1:-'amor'}
traj='mtd.fit.xtc'
binning="120 0.08"} # (9.999726 - 0.000248)/120 # (max cv - min cv )/120 nbins
bsize=100
bmin=1
bmax=10000 # 1000
bstp=100 # 10

kbt=2.494339 # boltzman constant

cv='d0'
col=2 # d0 column in colvar
bcol=7 # metad bias column

cv_max=10
cv_min=0.0002
nb=120
bw=0.08

if [[ ! -e "mcfile" ]]; then
    echo "generating mcfile"
    echo "DUMPMASSCHARGE FILE=mcfile" > dump.dat
    gmx_mpi mdrun -s mtd.tpr -nsteps 1 -plumed dump.dat
else
    echo "mcfile exists"
fi

if [[ ! -e "colvar.reweight" ]]; then
    echo "reweight on $lig binning $binning on $traj"
    
    sed -e "s/#RESTART/RESTART/" \
        -e 's/HEIGHT=[^ ]\+/HEIGHT=0.0/' \
        -e 's/PACE=[0-9.]\+/PACE=10000000/g' \
        -e '/^\.\.\.$/i \\tFILE=HILLS' \
        -e 's/STRIDE=500/STRIDE=1/g' \
        -e 's/FILE=colvar/FILE=colvar.reweight/g' $lig.dat > mtd_reweight.dat
    
    cat << EOF >> mtd_reweight.dat
    ### reweight histograms
    as: REWEIGHT_BIAS ARG=metad.bias TEMP=298
    
    h$cv: HISTOGRAM ARG=$cv LOGWEIGHTS=as BANDWIDTH=$bw GRID_MIN=$cv_min GRID_MAX=$cv_max GRID_BIN=$nb
    f$cv: CONVERT_TO_FES GRID=h$cv TEMP=298 MINTOZERO
    DUMPGRID GRID=f$cv FILE=f$cv.dat
    
EOF
    
    plumed driver --plumed mtd_reweight.dat --mf_xtc $traj --mc mcfile
else
    echo "colvar.reweight exists"
fi

echo "reweight on $lig binning $binning"

# MANUAL REWEIGHT

# gnuplot
# p 'd0_sort.weight' u 1:(-2.49*(log($2))) w l
# p 'h0.weight' u 1:2, 'colvar.reweight' u 4:(exp(($9-229.3)/2.49))

#! FIELDS time d0 d1 d2 d3 d4 metad.bias uwall3.bias uwall3.force2 lwall1.bias lwall1.force2 lwall2.bias lwall2.force2

if [[ ! -e "${cv}.weight" ]]; then
    echo "manual reweight"

bmax=`awk -v bcol="$bcol" 'BEGIN{max=0.}{if($1!="#!" && $bcol>max)max=$bcol}END{print max}' colvar.reweight`
echo $bmax $kbt

awk -v kbt="$kbt" -v bmax="$bmax" -v col="$col" -v cv="$cv" -v bcol="$bcol" \
    '{if($1!="#!") print $col,exp(($bcol-bmax)/kbt),-kbt*(log(exp(($bcol-bmax)/kbt)))}' \
		colvar.reweight \
    		| sed -e "1s/^/#! FIELDS ${cv}        weight        FES\n/" > "${cv}.weight"

else
    echo "${cv}.weight exists"
fi

# BLOCK ANALYSIS
# ./04h_blocks.sh 'd0' 100 1 100000 1000 # 10000 blocks = 100 ns

if [[ ! -d "blocks.${cv}" ]]; then
    echo "creating directory blocks.${cv}"
    mkdir blocks.${cv}
else
    echo "blocks.${cv} exists"
fi

cd blocks.${cv}

if [[ ! -L "do_block_fes.py" ]]; then
    echo "link do_block_fes.py"
    ln -s ../../scripts/do_block_fes.py .
else
    echo "do_block_fes.py exists"
fi

if [[ ! -f "${cv}.weight" ]]; then
    echo "copy ${cv}.weight"
    grep -v "\#" ../${cv}.weight | awk '{print $1,$2}' > ${cv}.weight
else
    echo "${cv}.weight exists"
fi

if [[ ! -f "err.block" ]]; then
    echo "calculating blocks"

    # Arguments of do_block_fes.py
# - FILE: input file, 1 column per CV + weights (optional)
# - NCV: number of CVs
# - *MIN: minimum value of CV
# - *MAX: max value of CV
# - *NBIN: # points in output free energy
# - KBT: temperature in energy units (kJoule/mol)
# - N: Block size
#
# * = repeat this block for each CV
# Example with 2 CVs:
# python3 do_block_fes.py phi_psi_w.dat 2 -3.141593 3.141593 50 -3.141593 3.141593 50 2.494339 100
#
#
# Author: Max Bonomi (mbonomi@pasteur.fr)

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

else
    echo "err.block exists"
fi

cd ..
