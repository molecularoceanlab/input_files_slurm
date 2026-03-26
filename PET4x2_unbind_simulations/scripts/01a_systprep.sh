#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

# system preparation
# 2 molecules of 4xMHET to auto aggregate in EQ
# syst prep for MTD CV distance from COM of PET filaments, aggregation energy to unpack solid PET
# structure and topology of PET as 4xMHET prepared with glyde, gaussian and acpype

gmx=gmx_mpi

# ln -s ../../templates/lig_HEMT/4MHET/UNK.acpype/UNK_GMX.gro lig.gro
# ln -s ../../templates/lig_HEMT/4MHET/UNK.acpype/UNK_GMX.top lig.top
# ln -s ../../templates/lig_HEMT/4MHET/UNK.acpype/UNK_GMX.itp lig.itp
# ln -s ../../templates/water/ffamber_tip3p.gro ffamber_tip3p.gro
# ln -s ../../templates/water/ffamber_tip3p.itp ffamber_tip3p.itp

# edit box with only one molecule of 4xMHET
#$gmx editconf -f lig.gro -o vacbox.gro -c -d 1.1 -bt dodecahedron
#$gmx editconf -f lig.gro -o vacbox.gro -c -d 2.1 -bt dodecahedron
#$gmx editconf -f lig.gro -o vacbox.gro -c -d 4.2 -bt dodecahedron

# add 2nd molecule
#$gmx insert-molecules -f vacbox.gro -ci lig.gro -nmol 1 -o dimer.gro

# update top
#sed -e 's/#include "UNK_GMX.itp"/#include "lig.itp"/' lig.top > solv.top
#sed -e '/^; UNK_GMX.top/a \\n; force field\n; Include forcefield parameters\n#include "amber99sb-ildn.ff/forcefield.itp"' \
#    -e '/^\[ defaults \]/,/^1               2               yes             0.5     0.8333/ s/^/;/' \
#    -e 's/#include "UNK_GMX.itp"/#include "lig.itp"\n\n; include solvent topology\n; Include water topology\n#include "amber99sb-ildn.ff\/tip3p.itp"/' \
#    -e "s/ UNK              1/ UNK              2/"  lig.top > dimer.top

#cp dimer.top solv.top

# solvate
#$gmx solvate -cp dimer.gro -cs ffamber_tip3p.gro -o solv.gro -p solv.top

# no ions as there are no charges to compensate without the protein

# gen ndx file for 2PETs
echo -e "ri 1\nri 2\nname 6 UNK1 \nname 7 UNK2\nq" |$gmx make_ndx -f solv.gro -o PETs.ndx

rm *#*#*
