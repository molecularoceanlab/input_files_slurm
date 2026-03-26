#!/usr/bin/env bash

# DESCRIPTION
# wrap and fit md
# syst=7nei md=eq
# cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

dt=$(date '+%d/%m/%Y %H:%M:%S')

syst=$1	
md=$2	

echo -e "\n\t$syst\t$md\n"
echo -e "\t$dti\n"

echo -e "C-alpha\ncomplex" | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.center.xtc -center -pbc mol -ur compact -n ../01_sysprep/complex.ndx
echo -e "C-alpha\ncomplex" | gmx_mpi trjconv -s $md.tpr -f $md.center.xtc -o $md.fit.xtc -fit rot+trans -n ../01_sysprep/complex.ndx
echo -e "complex" | gmx_mpi trjconv -s $md.tpr -f $md.fit.xtc -o $md.fit.pdb -dump 0 -n ../01_sysprep/complex.ndx
echo 'complex' | gmx_mpi trjconv -s $md.tpr -f $md.gro -o $md.pdb -n ../01_sysprep/complex.ndx

rm $md.center.xtc
rm *#*#*
