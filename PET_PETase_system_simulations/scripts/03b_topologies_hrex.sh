#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

gmx=gmx_mpi
nrep=8

# Get the protein ID from the command-line argument
prot=6eqe
mdp=${1:-"hrex"}    # hrex # heat

amor="amor"
crys="crys"

for lig in "$amor" "$crys"; do

    for((i=0;i<nrep;i++)); do

        echo -e "$prot $lig $i"        
        #$gmx grompp -f ${lig}/par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c cluster.gro -r cluster.gro -p ${lig}/hrex${i}.top -o ${lig}/r${i}/hrex.tpr -pp ${lig}/r${i}/hrex_pp.top -po ${lig}/r${i}/hrex_out.mdp -maxwarn 1
        $gmx grompp -f par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c eq2.tpr -r eq2.tpr -t $lig/eq2.cpt -p par_hrex/hrex${i}.top -o ${lig}/hrex_mtd/r${i}/hrex.tpr -pp ${lig}/hrex_mtd/r${i}/hrex_pp.top -po ${lig}/hrex_mtd/r${i}/hrex_out.mdp -maxwarn 1

    done
done

rm *#*#*
