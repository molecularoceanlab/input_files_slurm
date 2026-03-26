#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

#echo 2 | gmx_mpi trjconv -s ../mtd.tpr -f ../mtd.fit.pdb -n ../pbc/PETs.ndx - o PETs.dry.pdb
#echo 2 | gmx_mpi trjconv -s ../mtd.tpr -f PET_0.3_0.5.gro -n ../pbc/PETs.ndx -o PET_0.3_0.5.xtc

#plumed driver --plumed amor_rw.dat --mf_xtc ../mtd.fit.short_100.xtc --mc ../pbc/mcfile
plumed driver --plumed plumed.dat --mf_xtc ../mtd.fit.short_100.xtc --mc ../pbc/mcfile

rm bck*
