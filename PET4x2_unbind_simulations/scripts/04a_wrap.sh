#!/usr/bin/env bash

#SBATCH -t 0-00:30:00
#SBATCH --mem-per-cpu=3750M
#SBATCH -N 1
#SBATCH --ntasks-per-node=8 # 16 inefficient for gmx
#SBATCH --cpus-per-task=4   # max 10 for gmx but cesga make it mandatory to use all
#   #SBATCH --gres=gpu
#SBATCH --job-name=wrap
#SBATCH --output=../../slurm/%x.%J.log   # Standard output and error log

# lig=amor
# sbatch --job-name=wrap_${lig}_2PET ./scripts/04a_wrap.sh mtd
# for lig in amor crys; do (cd $lig; ../scripts/04a_wrap.sh mtd 10; cd ..) &; done; wait

start_time=$(date +%s)

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

md=${1:-"mtd"}
skip=${2:-"20"}

if ls ${md}.part*.xtc 1> /dev/null 2>&1; then
    # check if trajectory is fragmented (no append)
    if [[ -f "${md}.xtc" ]]; then
        rm ${md}.xtc
    fi
    unset xtc empty
    for i in $(ls ${md}*part*xtc); do
        if [[ -s $i ]]; then
            echo "$i NOT empty"; xtc="${xtc} ${i}";
        else
            echo "$i  IS empty"; empty="${empty} ${i}";
        fi
    done
    echo xtc $xtc
    echo empty $empty
    #gmx_mpi trjcat -f ${md}.part*.xtc -o ${md}.xtc
    gmx_mpi trjcat -f $xtc -o ${md}.xtc
fi

#echo 2 0 | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.pdb -dump 0 

echo 6 0 | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.center.xtc -center -pbc mol -ur compact -skip ${skip} -n ../PETs.ndx 
echo 6 0 | gmx_mpi trjconv -s $md.tpr -f $md.center.xtc -o $md.fit.xtc -fit rot+trans -n ../PETs.ndx
echo 0   | gmx_mpi trjconv -s $md.tpr -f $md.fit.xtc -o $md.fit.pdb -dump 0

if [[ -f "$md.center.xtc" ]]; then
    rm $md.center.xtc
fi

if ls *#*#* 1> /dev/null 2>&1; then
    rm *#*#*
fi

sleep 5

end_time=$(date +%s)

elapsed_time=$((end_time - start_time))

minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))

echo "END wrapping: ${minutes} m : ${seconds} s"

