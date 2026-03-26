#!/usr/bin/env bash

# DESCRIPTION
# edit mdp file for equilibrium in hrex after pulling
# from main directory. one for all systems
# ./scripts/02_mineq/02j_hrex_eq_mdp.sh

source ~/.projects_startup.sh > /dev/null 2>&1

# parameters for replicas
nrep=8
tmin=298
tmax=698

#   edit hrex.mdp

sed -e "s/nstlist                 = 20        ; largely irrelevant with Verlet/nstlist                 = 40        ; largely irrelevant with Verlet/"  \
	-e "s/tc-grps                 = Protein_HEM Water_and_ions    ; two coupling groups - more accurate/tc-grps                 = complex_Protein_UNK Water_and_ions ; two coupling groups - more accurate/" \
	-e "s/ref_t                   = 300   300                     ; reference temperature, one for each group, in K/ref_t                   = $tmin   $tmin                     ; reference temperature, one for each group, in K/" \
	templates/par_md/4_md1.mdp > par_md/hrex.mdp
