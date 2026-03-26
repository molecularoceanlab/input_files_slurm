#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# usign pulling starting point and top as also protein CA restraints in topology
# additional restraints in plumed

prot=6eqe
mdp=${1:-"eq2"}

amor="amor"
crys="crys"

if [[ "$mdp" == "eq2" ]]; then
    echo -e "preprocess eq2 stretch ..."    
elif [[ "$mdp" == "eq2_frozen" ]]; then
    echo -e "preprocess eq2 frozen ..."
else
    echo -e "Error: Unsupported mdp value '$mdp'. Please use 'eq2' or 'eq2_frozen'."
fi

$gmx grompp -f par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c cluster.gro -r cluster.gro -p ../01_sysprep/posres.top -o ${mdp}.tpr -pp ${mdp}_pp.top -po ${mdp}_out.mdp -maxwarn 1

#$gmx grompp -f par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c ../02_mineq/pull.gro -r ../02_mineq/pull.gro -p ../02_mineq/pull.top -o eq2.tpr -pp eq2_pp.top -po eq2_out.mdp -maxwarn 1

for lig in "$amor" "$crys"; do
    echo -e "$prot $lig $mdp"        
    cd $lig
    ls ../${mdp}* .
    ln -s ../${mdp}* .
    ln -s ../cluster* .
    cd ..
done

rm *#*#*

