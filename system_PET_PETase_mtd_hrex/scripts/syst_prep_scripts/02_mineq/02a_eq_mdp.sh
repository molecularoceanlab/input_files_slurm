#!/usr/bin/env bash

#   DESCRIPTION
#	edit mdp files for simulations
#	eq.mdp for equilibrium with posres on the lig and ca
#	from experiment main directory
#	./scripts/02_mineq/02a_eq_mdp.sh

source ~/.projects_startup.sh > /dev/null 2>&1

templates=templates
par_md=$templates/par_md

#   edit eq.npt.mdp from template
#	apply posres, generate velocities, starting md	

sed -e "s/define                  = -DPOSRES -DPOSRES_CA -DPOSRES_LIG ; position restrain the protein and ligand/define                  = -DPOSRES_CA -DPOSRES_LIG; position restrain the protein CA and ligand heavy atoms/" \
    -e "s/continuation            = yes       ; continuing from NVT/continuation            = no        ; starting from NVT/" \
    -e "s/tc-grps                 = Protein_HEM Water_and_ions    ; two coupling groups - more accurate/tc-grps                 = complex_Protein_UNK Water_and_ions    ; two coupling groups - more accurate/" \
    -e "s/gen_vel                 = no        ; velocity generation off after NVT/gen_vel                 = yes       ; velocity generation on starting from NPT/" \
    -e "/gen_vel                 = yes/agen_temp                = 298       ; temperature for Maxwell distribution\ngen_seed                = -1        ; generate a random seed" \
        $par_md/3_eq1.npt.mdp > par_md/eq.mdp
