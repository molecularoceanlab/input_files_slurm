#!/usr/bin/env bash

#SBATCH -t 0-02:00:00
#   #SBATCH --mem-per-cpu=3750M
#SBATCH --mem-per-cpu=375M # from 90 M used x 3 safety factor
#SBATCH -N 1
#SBATCH --ntasks-per-node=8 # 16 inefficient for gmx
#SBATCH --cpus-per-task=4   # max 10 for gmx but cesga make it mandatory to use all
#   #SBATCH --gres=gpu
#SBATCH --job-name=wrap
#SBATCH --output=../../../slurm/%x.%J.log   # Standard output and error log

# lig=amor i=0
# sbatch --job-name=wrap_${lig}_${i} ../scripts/04b_wrap.sh mtd

start_time=$(date +%s)

source ~/.projects_startup.sh > /dev/null 2>&1

md=${1:-"mtd"}
skip=${2:-"20"}

# gmx_mpi check -f $md.fit.xtc
# for lig in amor crys; do for i in 0 1 2 3; do (cd $lig/cv_${i}; echo $lig $i; ../../scripts/04b_wrap.sh mtd; cd ../..) &; done; done; wait

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
    gmx_mpi trjcat -f $xtc -o ${md}.xtc
    #gmx_mpi trjcat -f ${md}.part*.xtc -o ${md}.xtc
fi

#if ls ${md}.part*.gro 1> /dev/null 2>&1; then
#    log=`ls ${md}.part*.log | tail -1`
#else
#    log=`ls ${md}.log | tail -1`
#fi
#
#last=`grep -A 1 "Step           Time" $log | tail -1 | awk '{print $2}'`
#
#if [[ -f "$md.gro" ]]; then
#    mv $md.gro ori_${md}.gro
#fi

echo 2 0 | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.pdb -dump 0

echo 2 0 | gmx_mpi trjconv -s $md.tpr -f $md.xtc -o $md.center.xtc -center -pbc mol -ur compact -skip ${skip}
echo 2 0 | gmx_mpi trjconv -s $md.tpr -f $md.center.xtc -o $md.fit.xtc -fit rot+trans
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
