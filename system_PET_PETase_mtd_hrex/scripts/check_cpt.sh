#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

md=${1:-"hrex"} # eq2

aligned=true
echo "" > check_cpt
echo "" > check

for i in {0..7}; do
    gmx_mpi check -f r$i/${md}.cpt &>> check
    time=$(grep "Last frame" check | awk '{print $5}' | tail -1)
    echo -e "cpt   \tr$i\t$time" &>> check_cpt
    if [[ "$i" == 0 ]]; then
        ref_time=$time
    fi
    if [[ "$ref_time" != "$time" ]]; then
    aligned=false
    fi
done

echo -e "cpt   \taln\t$aligned" &>> check_cpt

aligned=true
echo "" >> check_cpt
echo "" > check

for i in {0..7}; do
    gmx_mpi check -f r$i/${md}_prev.cpt &>> check
    time=$(grep "Last frame" check | awk '{print $5}' | tail -1)
    echo -e "cpt_pr\tr$i\t$time" &>> check_cpt
    if [[ "$i" == 0 ]]; then
        ref_time=$time
    fi
    if [[ "$ref_time" != "$time" ]]; then
    aligned=false
    fi
done

echo -e "cpt_pr\taln\t$aligned" &>> check_cpt

echo "" >> check_cpt
echo "" > check

cat check_cpt
