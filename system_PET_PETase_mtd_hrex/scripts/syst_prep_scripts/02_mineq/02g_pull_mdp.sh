#!/usr/bin/env bash

#   DESCRIPTION
#	edit mdp files for simulations
#	pull.mdp for equilibrium with posres on the ca, lig free to move
#	from experiment main directory
#	./scripts/02_mineq/02g_pull_mdp.sh

source ~/.projects_startup.sh > /dev/null 2>&1

templates=templates
par_md=$templates/par_md

#   edit ligpull.mdp from template
#	apply posres on CA, continue simulation from eq

sed -e "s/;define                  = -DPOSRES_CA ; commented -DPOSRES_LIG -DPOSRES -DPOSRES_WATER/define                  = -DPOSRES_CA; position restrain on protein CA/" \
    -e "s/nsteps                  = 20000      ;/nsteps                  = 50000      ;/" \
    -e "s/tc-grps                 = Protein_UNK Water_and_ions    ; two coupling groups - more accurate/tc-grps                 = complex_Protein_UNK Water_and_ions    ; two coupling groups - more accurate/" \
    -e "s/ref_t                   = 300   300                     ; reference temperature, one for each group, in K/ref_t                   = 298   298                     ; reference temperature, one for each group, in K/" \
        $par_md/5_ligpull.mdp > par_md/pull.mdp

#   pulling
#   new pulling on xray coordinates
#   instead of pulling the central carbon of the 4MHET towards the cat Ser oxygen
#   use monomer coordinates from 5xh3 to pull the ligand in position for the equilibrium and the hrex
