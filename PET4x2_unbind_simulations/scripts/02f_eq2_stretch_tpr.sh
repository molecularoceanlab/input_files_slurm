#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1
# equilibrium to stretch and center UNK1
# additional restraints in plumed

amor="amor"
crys="crys"

$gmx grompp -f par_md/2d_npt_stretch.mdp -c ../02_mineq/npt.gro -p ../02_mineq/npt.top -o eq2.tpr -pp eq2_pp.top -po eq2_out.mdp -maxwarn 1

for lig in "$amor" "$crys"; do
    echo -e "$prot $lig"        
    cd $lig
    ls ../eq2* .
    ln -s ../eq2* .
    cd ..
done

rm *#*#*

