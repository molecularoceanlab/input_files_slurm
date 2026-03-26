#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

xtc=${1:-'../hrex.fit.xtc'}
dat=${2:-'dump_d0.dat'}
gro=${3:-'d0_0.35.gro'}

lastatom=$(cat ../hrex.fit.pdb | awk '{if ($4=="UNK") print $2}' | tail -1)

rm $gro colvar.dump

grep DISTANCE ../mtd_reweight.dat > $dat

echo "
UPDATE_IF ARG=d0 LESS_THAN=0.35
DUMPATOMS ATOMS=1-$lastatom FILE=d0_0.35.gro
UPDATE_IF ARG=d0 END

PRINT ARG=* FILE=colvar.dump
" >> dump_d0.dat

cat dump_d0.dat

plumed driver --plumed dump_d0.dat --mf_xtc $xtc
