#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

md=${1:-"mtd"}
lig=${2:-"amor"}

if [[ "$md" == "hrex" ]]; then
    dir=$lig/r0
    bk="../.."
elif [[ "$md" == "mtd" ]]; then
    dir=$lig
    bk=".."
else
    echo check parameters
fi

echo $md $lig $dir

cd $dir

if ls ${md}.part*.log 1> /dev/null 2>&1; then
    unset last_log last_empty
    for i in $(ls ${md}*part*log); do
        if [[ -s $i ]]; then
            #echo "$i NOT empty"
            last_log=$i
        else
            #echo "$i  IS empty"
            last_empty=$i
        fi
    done
fi

du -sch $last_log $last_empty
time=$(grep -A 1 "Step           Time" $last_log | tail -1 | awk '{print $2}')
echo $lig $last_log $time

cd $bk  #.. or ../..

#log=$(ls  $lig/${md}*part*.log | tail -1); time=$(grep -A 1 "Step           Time" $log | tail -1 | awk '{print $2}')
#echo $lig $i $time
