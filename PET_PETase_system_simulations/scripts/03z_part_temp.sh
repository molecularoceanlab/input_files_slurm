#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# parameters for replicas
nrep=8
tmin=298
tmax=698

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

# HEAT

echo -e "updating topology hot atoms for lig"

awk -v NAME=UNK '/ atoms /,/ bonds /{if (NF >= 8 && $4==NAME ) $2 = $2 "_" }1' eq2_pp.top > par_hrex/lighot.top

echo -e "\npreparing heating $nrep replicas at temperatures:\n$list\n"

for((i=0;i<nrep;i++)); do

    rep=$(($i+1))
    temp=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $rep;}')
    lambda=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $1/$rep;}')

    echo -e "\nreplica $i - temp $temp K - lambda T[0]/T[i] $lambda\n"

    # PARTIAL TEMPERING

    echo -e "partial tempering for $syst"

    plumed partial_tempering $lambda < par_hrex/lighot.top > par_hrex/hrex${i}.top

done

