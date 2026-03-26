#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# for lig in amor crys; do for i in 1 2 3; do if [[ "$i" -eq 1 ]]; then v0="h0" v1="h1"; elif [[ "$i" -eq 2 ]]; then v0="h0" v1="s0"; elif [[ "$i" -eq 3 ]]; then v0="h1" v1="s0"; fi; echo $lig $i $v0 $v1; ( cd $lig/cv_${i}; ../scripts/04c_sumhills.sh $v0 $v1; cd ../../) &; done; done; wait
# for lig in amor crys; do ( cd $lig/cv_1; ../../scripts/04c_sumhills.sh "h0" "h1" 2500 ; cd ../.. ) &; done; wait

cv_0=${1:-"h0"}
cv_1=${2:-"h1"}
stride=${3:-"2500"}

start_time=$(date +%s)

if [[ ! -d "s${stride}" ]]; then
    echo mkdir s${stride}
    mkdir s${stride}
else
    echo dir s${stride} exists
fi

for file in s2d.dat s${cv_0}.dat s${cv_1}.dat s${stride}/s${cv_0}_*.dat s${stride}/s${cv_1}_*.dat ; do
    if [[ -f "$file" ]]; then
        echo removing previous $file
        rm $file
    else echo sumhills for $cv_0 $cv_1
    fi
done

plumed sum_hills --hills HILLS --mintozero --outfile s${cv_0}.dat --idw ${cv_0} --kt 2.494339 &
plumed sum_hills --hills HILLS --mintozero --outfile s${cv_1}.dat --idw ${cv_1} --kt 2.494339 &
plumed sum_hills --hills HILLS --mintozero --outfile s${stride}/s${cv_0}_ --idw ${cv_0} --kt 2.494339 --stride 5000 &
plumed sum_hills --hills HILLS --mintozero --outfile s${stride}/s${cv_1}_ --idw ${cv_1} --kt 2.494339 --stride 5000 &
plumed sum_hills --hills HILLS --mintozero --outfile s2d.dat &
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
