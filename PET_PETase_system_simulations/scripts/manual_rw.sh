#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# gnuplot
# p 'd0_sort.weight' u 1:(-2.49*(log($2))) w l
# p 'h0.weight' u 1:2, 'colvar.reweight' u 4:(exp(($9-229.3)/2.49))

kbt=2.494339

# mtd bias column
bcol=9

bmax=`awk -v bcol="$bcol" 'BEGIN{max=0.}{if($1!="#!" && $bcol>max)max=$bcol}END{print max}' colvar.reweight`

# Define collective variables (CVs) with their corresponding column numbers
declare -A cvs
cvs=( ["h0"]=4 ["h1"]=5 ["d0"]=2 ["s0"]=6 ["x0"]=7 ["x1"]=8 )
#cvs=( ["h0"]=4 ["h1"]=5 ["d0"]=2 )

##manual
#cv='h0'
#awk '{if($1!="#!") print $4,exp(($9-bmax)/kbt)}' kbt=$kbt bmax=$bmax colvar.reweight \
#    | sed -e "1s/^/#! FIELDS ${cv}        weight\n/" > h0_manual.weight

# Loop through each CV and compute the corresponding weight file
for cv_name in "${!cvs[@]}"; do
    cv_col=${cvs[$cv_name]}  # Get column number
	echo $cv_name $cv_col
    awk -v bcol="$bcol" -v cv_col="$cv_col" -v kbt="$kbt" -v bmax="$bmax" \
        '{if($1!="#!") print $(cv_col),exp(($bcol-bmax)/kbt)}' colvar.reweight \
        | sed -e "1s/^/#! FIELDS ${cv_name}        weight\n/"> "${cv_name}.weight"
#    cat "${cv_name}.weight" | sort -g -k1 \
#       | sed -e "1s/^/#! FIELDS ${cv_name}        weight\n/" > "${cv_name}_sort.weight"
done

#   h0 2D
# Loop through each CV and compute the corresponding weight file
for cv_name in "${!cvs[@]}"; do
    if [[ "$cv_name" != "h0"  ]]; then
        cv_col=${cvs[$cv_name]}  # Get column number
        echo h0 2D $cv_name $cv_col
        awk -v bcol="$bcol" -v cv_col="$cv_col" -v kbt="$kbt" -v bmax="$bmax" \
            '{if($1!="#!") print $5,$(cv_col),exp(($bcol-bmax)/kbt)}' colvar.reweight \
            | sed -e "1s/^/#! FIELDS h0        ${cv_name}        weight\n/" > "h0_${cv_name}_2D.weight"
#        cat "h0_${cv_name}_2D.weight" | sort -g -k1 \
#            | sed -e "1s/^/#! FIELDS h0        ${cv_name}        weight\n/" > "h0_${cv_name}_2D_sort.weight"
    fi
done

#   h1 2D
# Loop through each CV and compute the corresponding weight file
for cv_name in "${!cvs[@]}"; do
    if [[ "$cv_name" != "h1"  ]]; then
        cv_col=${cvs[$cv_name]}  # Get column number
        echo h1 2D $cv_name $cv_col
        awk -v bcol="$bcol" -v cv_col="$cv_col" -v kbt="$kbt" -v bmax="$bmax" \
            '{if($1!="#!") print $5,$(cv_col),exp(($bcol-bmax)/kbt)}' colvar.reweight \
            | sed -e "1s/^/#! FIELDS h1        ${cv_name}        weight\n/" > "h1_${cv_name}_2D.weight"
#        cat "h1_${cv_name}_2D.weight" | sort -g -k1 \
#            | sed -e "1s/^/#! FIELDS h1        ${cv_name}        weight\n/" > "h1_${cv_name}_2D_sort.weight"
    fi
done

echo d0 2 s0 6 2D
awk -v bcol="$bcol" -v kbt="$kbt" -v bmax="$bmax" \
    '{if($1!="#!") print $2,$6,exp(($bcol-bmax)/kbt)}' colvar.reweight \
    | sed -e "1s/^/#! FIELDS d0        s0        weight\n/" > "d0_s0_2D.weight"
#cat "d0_s0_2D.weight" | sort -g -k1 \
#    | sed -e "1s/^/#! FIELDS d0        s0        weight\n/" > "d0_s0_2D_sort.weight"



