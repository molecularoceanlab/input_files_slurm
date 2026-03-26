#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# parameters for replicas
nrep=8
tmin=298
tmax=698
dir=par_hrex
ori_top='../02_mineq/npt.top'

# build geometrical progression
# temperature for heating replicas

list=$(
awk -v n=$nrep \
    -v tmin=$tmin \
    -v tmax=$tmax \
    'BEGIN{for(i=0;i<n;i++){
    t=tmin*exp(i*log(tmax/tmin)/(n-1));
    printf(t); if(i<n-1)printf(",");
        }
    }'
)

#   from FC parameters, not clear how they are recovered. only for mtd
heights=(0.5 0.564646 0.637648 0.720091 0.813191 0.918329 1.03706 1.17114)

mkdir -p $dir

echo 'generate topology with all lig hot atoms'
# adding an underscore on atomtype for ligand "ca" -> "ca_"
# !!! pull.top has prot restraints!!! so hot topology will too! to releave restraints start from complex.top in initial system folder
awk -v NAME=UNK '/ atoms /,/ bonds /{if (NF >= 8 && $4==NAME ) $2 = $2 "_" }1' $ori_top > $dir/lighot.top
# only heavy atoms ???
# awk -v NAME=UNK '/ atoms /,/ bonds /{
#     if (NF >= 8 && $4==NAME && $2!~"^h") {
#         $1 = "    " $1; $2 = "  " $2 "_"
#         }
#     }1' pull.top > hrex/lighot.top

# HEAT

echo -e "\npreparing heating $nrep replicas at temperatures:\n$list\n"

for((i=0;i<nrep;i++)); do

    rep=$(($i+1))
    temp=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $rep;}')
    lambda=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $1/$rep;}')

    echo -e "\npartial tempering replica $i - temp $temp K - lambda T[0]/T[i] $lambda\n"

    # PARTIAL TEMPERING

    plumed partial_tempering $lambda < $dir/lighot.top > $dir/hrex${i}.top

done

