#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# edit eq.mdp extent infinite and continue md from pulling

sed \
    -e "s/nsteps                  = 50000     ;/nsteps                  = -1        ;/" \
    -e "s/continuation            = no        ; starting from NVT/continuation            = yes       ; starting from pull/" \
    -e "s/gen_vel                 = yes       ; velocity generation on starting from NPT/gen_vel                 = no        ; velocity generation starting from pull/" \
    -e "/gen_temp/d" \
    -e "/gen_seed/d" \
    par_md/eq.mdp > par_md/eq2.mdp

sed \
    -e "s/define                  = -DPOSRES_CA -DPOSRES_LIG/define                  = -DPOSRES/" \
    par_md/eq2.mdp > par_md/eq2_frozen.mdp
