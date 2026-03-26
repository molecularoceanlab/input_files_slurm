#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# for lig in amor crys; do echo $lig; (cd $lig; ../scripts/04b_sumhills.sh ; cd ..) &; done; wait

start_time=$(date +%s)

stride=${1:-"5000"}
sdir="s${stride}"
#sdir="s100"     # s100

if [[ -f sd0.dat ]]; then
	echo removing previous $file
	rm $file
else echo sumhills for d0
fi

if [[ ! -d "$sdir" ]]; then
    echo make $sdir
    mkdir $sdir
else
    echo removing fes_i.dat files
    rm $sdir/sd0_*.dat
fi

(
#plumed sum_hills --hills HILLS --mintozero --outfile sd0.dat &
plumed sum_hills --hills HILLS --mintozero --outfile $sdir/sd0_ --stride $stride
)
wait

rm *bck.*

if ls *#*#* 1> /dev/null 2>&1; then
    rm *#*#*
fi

sleep 5

end_time=$(date +%s)

elapsed_time=$((end_time - start_time))

minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))

echo "END sumhills: ${minutes} m : ${seconds} s"

