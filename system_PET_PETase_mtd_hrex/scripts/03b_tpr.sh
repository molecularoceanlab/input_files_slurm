#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

gmx=gmx_mpi
nrep=1

# Get the protein ID from the command-line argument
prot=6eqe
mdp=${1:-"md"}    # hrex # heat

amor="amor"
crys="crys"

for lig in "$amor" "$crys"; do

    echo -e "$prot $lig"        

    #$gmx grompp -f ${lig}/par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c ${lig}/eq_${lig}_fr.gro -r ${lig}/eq_${lig}_fr.gro -p ${lig}/eq_${lig}_fr.top -o ${lig}/mtd.tpr -pp ${lig}/mtd_pp.top -po ${lig}/mtd_out.mdp -maxwarn 1
    $gmx grompp -f ${lig}/par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c ${lig}/eq2_${lig}_fr.gro -r ${lig}/eq_${lig}_fr.gro -p ${lig}/eq_${lig}_fr.top -o ${lig}/mtd.tpr -pp ${lig}/mtd_pp.top -po ${lig}/mtd_out.mdp -maxwarn 1

    for((i=0;i<nrep;i++)); do

        cd $lig/cv_${i}

        ln -s ../mtd* .
        
        cd ../..
    done

done

rm *#*#*
