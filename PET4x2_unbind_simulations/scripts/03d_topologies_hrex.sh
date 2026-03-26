#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

gmx=gmx_mpi
nrep=8

# Get the protein ID from the command-line argument
mdp=${1:-"hrex"}    # hrex # heat

amor="hr_a"
crys="hr_c"

for lig in "$amor" "$crys"; do

    for((i=0;i<nrep;i++)); do

        echo -e "generate md parameters tpr for $lig $i"        
        mkdir -p $lig/r$i
        $gmx grompp -f par_md/3b_${mdp}.mdp -n ../01_sysprep/PETs.ndx -c eq2.tpr -r eq2.tpr -t $lig/eq2.cpt -p par_hrex/hrex${i}.top -o ${lig}/r${i}/hrex.tpr -pp ${lig}/r${i}/hrex_pp.top -po ${lig}/r${i}/hrex_out.mdp -maxwarn 1

    done
done

rm *#*#*

