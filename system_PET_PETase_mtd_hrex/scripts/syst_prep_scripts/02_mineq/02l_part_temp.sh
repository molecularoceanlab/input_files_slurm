#!/usr/bin/env bash

# DESCRIPTION
# partial tempering for hrex equilibration after pulling
# generates tpr for replicas to run simulation
# one per system
# run from syst/02_mineq directory
# syst=7nei
# cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02l_part_temp.sh $syst; cd ../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02l_part_temp.sh $syst; cd ../../../; fi; done


source ~/.projects_startup.sh > /dev/null 2>&1

syst=$1

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

echo -e "\npreparing heating $nrep replicas at temperatures:\n$list\n"

for((i=0;i<nrep;i++)); do

    rep=$(($i+1))
    temp=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $rep;}')
    lambda=$(echo -e "$list" | awk -v rep=$rep 'BEGIN{FS=",";}{print $1/$rep;}')

    echo -e "\nreplica $i - temp $temp K - lambda T[0]/T[i] $lambda\n"
    [ -d "hrex/r${i}" ] && echo -e "Directory hrex/r${i} exists." || (echo -e "creating directory hrex/r${i}" && mkdir hrex/r${i})

    # PARTIAL TEMPERING

	echo -e "partial tempering for $syst"

    plumed partial_tempering $lambda < hrex/lighot.top > hrex/hrex${i}.top

    echo -e "generates hrex.tpr per replicas"

    cd hrex/r${i}

        echo -e "hrex.tpr rep $i"

        $gmx grompp -f ../../../../../par_md/hrex.mdp -c ../../pull.gro -r ../../pull.gro -p ../hrex${i}.top -o hrex.tpr -pp hrex_pp.top -po hrex_out.mdp -n ../../../01_sysprep/complex.ndx -maxwarn 1

        rm *#*#*
        rm bck.* ../bck.*

    cd ../..

done
