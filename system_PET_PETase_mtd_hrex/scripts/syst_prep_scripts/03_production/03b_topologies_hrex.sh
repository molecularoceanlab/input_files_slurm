#!/usr/bin/env bash

# loads modules if on cesga
source ~/.projects_startup.sh > /dev/null 2>&1

# partial tempered topolgies from pull hrex eq without CA restraints for production
# mkdir -p amor/r$i crys/r$i

# syst=7nei frame=2679; syst=6ths frame=2210; syst=6tht frame=2068
# cd systs/$syst/03_production; echo $syst $frame; ../../../scripts/03_production/03b_topologies_hrex.sh $syst $frame; cd ../../../
# heat at 350K mdp=heat | mdp=hrex
# syst=6eqe frame=1 mdp="heat"
# cd systs/$syst/03_production; echo $syst $frame $mdp; ../../../scripts/03_production/03b_topologies_hrex.sh $syst $frame $mdp; cd ../../../

for file in $(ls ../02_mineq/hrex/*.top); do
    echo $file
    name=$(basename $file)
    grep -v "    1        500        500        500" $file > ${name}
    sed -i '/; position restraints for C-alpha of Protein in water/,+3d' ${name}
done

gmx=gmx_mpi
nrep=8

# Get the protein ID from the command-line argument
prot=$1
frame=$2
mdp=${3:-"hrex"}    # hrex # heat

# Check the value of mdp and set variables accordingly
if [ "$mdp" = "hrex" ]; then
    amor="amor"
    crys="crys"
elif [ "$mdp" = "heat" ]; then
    amor="a350"
    crys="c350"
fi

# extract cluster 1 last frame

#echo 'System' | gmx_mpi trjconv -f ../02_mineq/hrex/r0/hrex.xtc -s ../02_mineq/hrex/r0/hrex.tpr -b $frame -e $frame -o cluster.gro -n ../01_sysprep/complex.ndx
echo -e "$prot $frame"

#   echo 'System' | $gmx trjconv -f ../02_mineq/hrex/r0/hrex.xtc -s ../02_mineq/hrex/r0/hrex.tpr -dump $frame -o cluster.gro -n ../01_sysprep/complex.ndx
#   echo 'System' | $gmx trjconv -f ../02_mineq/hrex/r0/hrex.xtc -s ../02_mineq/hrex/r0/hrex.tpr -dump $frame -o cluster.pdb -n ../01_sysprep/complex.ndx

for lig in "$amor" "$crys"; do

    for((i=0;i<nrep;i++)); do

        echo -e "$prot $lig $i"        
        $gmx grompp -f ../../../par_md/${mdp}.mdp -n ../01_sysprep/complex.ndx -c cluster.gro -r cluster.gro -p hrex${i}.top -o ${lig}/r${i}/hrex.tpr -pp ${lig}/r${i}/hrex_pp.top -po ${lig}/r${i}/hrex_out.mdp -maxwarn 1

    done
done

rm *#*#*
