#!/usr/bin/env bash

# DESCRIPTION
# check nsteps per simulation

# no hrex 1 system

# dt=$(date '+%d/%m/%Y %H:%M:%S'); title=$(echo -e "\n\tsyst\ttraj\tStep\tTime ps"); echo -e "$dt $title"; syst=7nei; md=eq; cd systs/$syst/02_mineq/; steps=$(../../../scripts/04_analysis/04a_check_steps.sh $syst $md); echo -e "$steps"; cd ../../..

# no hrex all system

# dt=$(date '+%d/%m/%Y %H:%M:%S'); title=$(echo -e "\n\tsyst\ttraj\tStep\tTime ps"); echo -e "$dt $title"; syst=7nei; md=eq; for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq/; steps=$(../../../scripts/04_analysis/04a_check_steps.sh $syst $md); echo -e "$steps"; cd ../../..; fi; done

# hrex replicas no append parts 1 system

# dt=$(date '+%d/%m/%Y %H:%M:%S'); title=$(echo -e "\n\tsyst\ttraj\tStep\t\tTime ps\t\treps"); echo -e "$dt $title"; syst=7nei; md=hrex; for i in {0..7}; do cd systs/$syst/02_mineq/hrex/r$i/; steps=$(../../../../../scripts/04_analysis/04a_check_steps.sh $syst $md); echo -e "$steps r$i"; cd ../../../../..; done

# hrex replicas no append parts all systems

# dt=$(date '+%d/%m/%Y %H:%M:%S'); title=$(echo -e "\n\tsyst\ttraj\tStep\t\tTime ps\t\treps"); echo -e "$dt $title"; syst=7nei; md=hrex; for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for i in {0..7}; do cd systs/$syst/02_mineq/hrex/r$i/; steps=$(../../../../../scripts/04_analysis/04a_check_steps.sh $syst $md); echo -e "$steps\tr$i"; cd ../../../../..; done; fi; done

# hrex production

# dt=$(date '+%d/%m/%Y %H:%M:%S'); title=$(echo -e "\n\tsyst\ttraj\tStep\t\tTime ps\t\treps"); echo -e "$dt $title"; syst=7nei; md=hrex; for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys a350 c350; do for i in {0..7}; do cd systs/$syst/03_production/$lig/r$i/; steps=$(../../../../../scripts/04_analysis/04a_check_steps.sh $syst $md $lig); echo -e "$steps\tr$i"; cd ../../../../..; done; done; fi; done \
# | awk '{printf "%10s %10s %10s %15s %10s\n", $1, $2, $3, $4, $5}' | sort -u \
# | awk '{printf "%10s %10s %10s %15s\n", $1, $2, $3, $4}' | sort -u; \
# dt=$(date '+%d/%m/%Y %H:%M:%S'); echo -e "$dt"

# tot
#syst=7nei; md=hrex; 
#dt=$(date '+%d/%m/%Y %H:%M:%S'); 
#title=$(echo -e "\n\tsyst\ttraj\tStep\t\tTime ps\t\treps"); 
#echo -e "$dt $title"; 
#for syst in $(ls systs); do 
#    for lig in amor crys a350 c350; do 
#        for i in {0..7}; do 
#            cd systs/$syst/03_production/$lig/r$i/; 
#            steps=$(../../../../../scripts/04_analysis/04a_check_steps.sh $syst $md $lig); 
#            echo -e "$steps\tr$i";
#            cd ../../../../..; done; done; done | awk '{printf "%10s %10s %10s %15s %10s\n", $1, $2, $3, $4, $5}' | sort -u | awk '{printf "%10s %10s %10s %15s\n", $1, $2, $3, $4}' | sort -u;
#dt=$(date '+%d/%m/%Y %H:%M:%S'); echo -e "$dt"

dt=$(date '+%d/%m/%Y %H:%M:%S')
title=$(echo -e "\n\tsyst\ttraj\tStep\t\tTime ps\t\treps")

syst=$1	
md=$2	
lig=$3
log=$(ls ${md}*.log | tail -1)
timesteps=$(grep -A 1 "Step           Time" ${log} | tail -1)
step=$(echo ${timesteps} | awk '{print $1}')
time=$(echo ${timesteps} | awk '{print $2}')

#echo -e "\t$syst\t$md\t$step\t$time"
echo -e "\t$syst\t$lig\t$step\t$time"
