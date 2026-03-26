#!/usr/bin/env bash

LIG=${1:-"amor"}
EXP=${2:-"hrex_mtd"}
REP=${3:-"r0"}
COLVAR=${4:-"colvar"}

echo "$LIG $EXP $REP $COLVAR"

file="$LIG/$EXP/$REP/$COLVAR"
ls $file
fields=(2 4 5 6 7 8)  # Correspond to the columns of d0, h0, h1, s0, x0, x1
labels=(d0 h0 h1 s0 x0 x1)

for i in "${!fields[@]}"; do
    col=${fields[$i]}
    label=${labels[$i]}
    awk -v col="$col" -v label="$label" '$(col) != "" && $1 !~ /^#/ {
        if (min == "" || $(col) < min) min = $(col)
        if (max == "" || $(col) > max) max = $(col)
    } END {
        printf "%s\tmin: %.3f\tmax: %.3f\n", label, min, max
    }' "$file"
done
