#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

md=${1:-"hrex"} # md

if [[ "$md" == "hrex"  ]]; then
    echo -e "MD\trep\tStep\tTime ps"
    for i in {0..7}; do
        unset last_log last_empty
        for log in $(ls -rt r$i/${md}.part*.log); do
			part=$(echo $log | awk -F "." '{print $2}')
			if [[ -s "r$i/${md}.${part}.xtc" ]]; then
                last_log="$log"
            else
                last_empty="$log"
            fi
        done
        elapsed=$(grep -A1 "Step           Time" $last_log | tail -1 | awk '{printf ("%s\t%s", $1,$2)}')
        echo -e "$md\tr$i\t$elapsed\t$last_log"
    done
	echo $last_empty
elif [[ "$md" == "mtd" ]]; then
    echo -e "MD\tStep\tTime ps"
    unset last_log last_empty
    for log in $(ls -rt ${md}.part*.log); do
		part=$(echo $log | awk -F "." '{print $2}')
		if [[ -s "${md}.${part}.xtc" ]]; then
            last_log="$log"
        else
            last_empty="$log"
        fi
    done
    elapsed=$(grep -A1 "Step           Time" $last_log | tail -1 | awk '{printf ("%s\t%s", $1,$2)}')
    echo -e "$md\t$elapsed"
	echo $last_empty
fi

