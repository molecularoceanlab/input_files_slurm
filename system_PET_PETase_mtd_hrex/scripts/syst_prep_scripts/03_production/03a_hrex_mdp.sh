#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# new mdp file with no posres
# no further eq. just cut first 100 ps of MD

tmin=298

#   edit hrex.mdp

sed \
    -e "s/nstlist                 = 20        ; largely irrelevant with Verlet/nstlist                 = 40        ; largely irrelevant with Verlet/" -e "s/tc-grps                 = Protein_HEM Water_and_ions    ; two coupling groups - more accurate/tc-grps                 = complex_Protein_UNK Water_and_ions ; two coupling groups - more accurate/" \
    -e "s/ref_t                   = 300   300                     ; reference temperature, one for each group, in K/ref_t                   = $tmin   $tmin                     ; reference temperature, one for each group, in K/" \
    templates/par_md/4_md1.mdp > par_md/hrex.mdp
