#!/usr/bin/env bash

#SBATCH -t 0-00:10:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --job-name=wrap
#SBATCH --output=../slurm/%x.%J.log   # Standard output and error log

# DESCRIPTION
# wrap and fit md
# syst=7nei md=eq
# cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../; fi; done
# hrex equilibrium 02_mineq
# syst=7nei md=hrex
# cd systs/$syst/02_mineq/hrex/r0/; ../../../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../../..
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq/hrex/r0/; ../../../../../scripts/02_mineq/02d_wrap.sh $syst $md ; cd ../../../../..; fi; done
#
# hrex mtd production
# syst=7nei md=hrex lig=amor
# cd systs/$syst/03_production/$lig/r0/; ../../../../../scripts/04_analysis/04b_wrap.sh $syst $md $lig; cd ../../../../..
# md=hrex; for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys; do ( cd systs/$syst/03_production/$lig/r0/; ../../../../../scripts/04_analysis/04b_wrap.sh $syst $md $lig ; cd ../../../../.. ) &; done; fi; done; wait
# md=hrex; for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys a350 c350; do ( cd systs/$syst/03_production/$lig/r0/; ../../../../../scripts/04_analysis/04b_wrap.sh $syst $md $lig ; cd ../../../../.. ) &; done; fi; done; wait
# md=hrex; for syst in $(ls systs); do for lig in a300 c300 a350 c350; do ( cd systs/$syst/03_production/$lig/r0/; ../../../../../scripts/04_analysis/04b_wrap.sh $syst $md $lig ; cd ../../../../.. ) &; done; done; wait
# md=hrex; for syst in $(ls systs); do for lig in a300 c300 a350 c350; do ( cd systs/$syst/03_production/$lig/r0/; sbatch --job-name=${syst}_${lig}_wrap --time=00:10:00 --mem-per-cpu=3750M --nodes=1 --output=../../../slurm/%x.%J.log ../../../../../scripts/04_analysis/04b_wrap.sh $syst $md $lig ; cd ../../../../.. ) &; done; done; wait
#
# SYMBOLIC LINKS TO 04_analysis folder
# syst=7nei lig=crys i=0
# cd systs/$syst/04_analysis/$lig/r$i/; ln -s ../../../03_production/${lig}.dat mtd.dat; cd ../../../../../;
# for file in HILLS colvar hrex.xtc hrex.tpr hrex.pdb hrex.fit.xtc hrex.fit.pdb; do cd systs/$syst/04_analysis/$lig/r$i/; ln -s ../../../03_production/$lig/r$i/$file* $file; cd ../../../../../; done
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys; do for file in HILLS colvar hrex.xtc hrex.tpr hrex.pdb hrex.fit.xtc hrex.fit.pdb; do cd systs/$syst/04_analysis/$lig/r$i/; ln -s ../../../03_production/$lig/r$i/$file* $file; cd ../../../../../; done ; done; fi; done
# high temp
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys a350 c350; do for file in HILLS colvar hrex.xtc hrex.tpr hrex.pdb hrex.fit.xtc hrex.fit.pdb; do cd systs/$syst/04_analysis/$lig/r$i/; ln -s ../../../03_production/$lig/r$i/$file* $file; cd ../../../../../; done ; done; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

dt=$(date '+%d/%m/%Y %H:%M:%S')

syst=$1	
md=$2
lig=$3
ndx=${4:-"../../../01_sysprep/complex.ndx"}   # ../01_sysprep/complex.ndx
gro=$md.gro

echo -e "\n\t$syst\t$md\n"
echo -e "\t$dti\n"

if ls ${md}.part*.xtc 1> /dev/null 2>&1; then
    # check if trajectory is fragmented (no append)
    gro=$(ls -rth hrex.part*.gro | tail -1)
    if ls ${md}.xtc 1> /dev/null 2>&1; then
        rm ${md}.xtc
    fi
    echo "concat traj parts"
	$gmx trjcat -f ${md}.part*.xtc -o ${md}.xtc
fi

echo -e "C-alpha\ncomplex" | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.center.xtc -center -pbc mol -ur compact -n $ndx
echo -e "C-alpha\ncomplex" | gmx_mpi trjconv -s $md.tpr -f $md.center.xtc -o $md.fit.xtc -fit rot+trans -n $ndx
echo -e "complex" | gmx_mpi trjconv -s $md.tpr -f $md.fit.xtc -o $md.fit.pdb -dump 0 -n $ndx
echo -e "complex" | gmx_mpi trjconv -s $md.tpr -f $gro -o $md.pdb -n $ndx

rm $md.center.xtc
rm *#*#*
