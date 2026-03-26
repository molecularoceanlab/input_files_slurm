#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# new mdp file with no posres
# ./scripts/03_production/03g_heat_mpd.sh

tmin=350

#   edit heat.mdp from hrex.mdp

sed \
    -e "s/ref_t                   = 298   298                     ; reference temperature, one for each group, in K/ref_t                   = $tmin   $tmin                     ; reference temperature, one for each group, in K/" \
    par_md/hrex.mdp > par_md/heat.mdp
