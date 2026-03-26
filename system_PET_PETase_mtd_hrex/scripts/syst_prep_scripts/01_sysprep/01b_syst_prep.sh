#!/usr/bin/env bash

#   DESCRIPTION
#   
#   system preparation from prot.pdb generates topologies and gro for gromacs
#   edit box conformation and add ligand topology and coordinates from acpype generated gromacs files
#   solvate the complex and add ions concentrations
#   generate posres and groups for the heating to pair the ligand with the protein
#   automatically adds ligand topology and posres to the complex topology
#   
#   for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/01_sysprep; ls; echo $syst; ../../../scripts/01_sysprep/01b_syst_prep.sh ; ls; cd ../../..; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

templates=../../../templates
lig_path=$templates/lig_HEMT/4MHET/UNK.acpype
lig_gro=UNK_GMX.gro
lig_itp=UNK_GMX.itp
water_path=$templates/water
water_gro=ffamber_tip3p.gro
water_itp=ffamber_tip3p.itp
par_md=$templates/par_md

# generate prot gmx files
$gmx pdb2gmx -f prot.pdb -ff amber99sb-ildn -o prot.gro -p prot.top -i posres.itp -water tip3p -ignh
# edit box conf
$gmx editconf -f prot.gro -o vacbox.gro -bt dodecahedron -c -d 1.1
# insert lig mol
ls $lig_path/$lig_gro
$gmx insert-molecules -f vacbox.gro -ci $lig_path/$lig_gro -nmol 1 -o complex.gro
# cp top file to manually edit and add lig topology to complex topology
cp prot.top complex.top # for bk sake
# add ligand topology inside the 
sed -e '/^#include "amber99sb-ildn.ff\/forcefield.itp"/a \\n;include ligand topology\n#include "'"$(echo $lig_path)"'\/UNK_GMX.itp"\n\n; ligand restraints heavy atoms\n'\
	-e '/^\[ molecules \]/{N;N; s/$/\nUNK                 1/}' prot.top > complex.top
# create top bk
cp complex.top solv.top
# solvete with water
$gmx solvate -cp complex.gro -cs $water_path/$water_gro -o solv.gro -p solv.top
# add ions
$gmx grompp -f $par_md/0_ions.mdp -c solv.gro -p solv.top -o ions.tpr -po ions.mdp -pp ions.top # -maxwarn 100 -r solv.gro ## only with restraints
echo SOL | $gmx genion -s ions.tpr -o ions.gro -p ions.top -pname NA -nname CL -conc 0.150 -neutral

# generate restraints and coupling groups
# prot POSRES_CA
echo C-alpha | $gmx genrestr -f ions.gro -o posres_ca.itp -fc 500 500 500
# complex coupling group for annealing and t ramps
# ligand posres_lig on the same ndx file
echo -e "\"protein\" | r UNK\nr UNK & ! a H*\nname 24 complex_Protein_UNK\nname 25 ligand_UNK_&_"\!"H*\nq" | $gmx make_ndx -f ions.gro -o complex.ndx
# ligand posres need to be from 1-90 as the posres refer to the molecule type which is before protein in top file
echo -e "r UNK & ! a H*\nname 3 ligand_UNK_&_"\!"H*\nq" | $gmx make_ndx -f $lig_path/$lig_gro -o ligand.ndx
echo -e "ligand" | $gmx genrestr -f $lig_path/$lig_gro -n ligand.ndx -o posres_lig.itp -fc 1000 1000 1000
# include positional restraints options on the topology file
# POSRES need to be inside the molecule section. for ligande before protein
# use placeholder "; ligand posres" to append POSRES_LIG define
sed -e '/^; Include Position restraint file/a \\n\n; protein restraints heavy atoms\n#ifdef POSRES\n#include "posres.itp"\n#endif\n\n; protein restraints CA\n#ifdef POSRES_CA\n#include "posres_ca.itp"\n#endif\n'\
	-e '/^; ligand restraints heavy atoms/a \\n#ifdef POSRES_LIG\n#include "posres_lig.itp"\n#endif\n'\
	ions.top > posres.top

rm *#*#*
rm bck.*

#   Group     0 (         System) has    90 elements
#   Group     1 (          Other) has    90 elements
#   Group     2 (            UNK) has    90 elements
#   Group     3 (      UNK_&_!H*) has    56 elements

#   Group     0 (         System) has 33244 elements
#   Group     1 (        Protein) has  3832 elements
#   Group     2 (      Protein-H) has  1953 elements
#   Group     3 (        C-alpha) has   265 elements
#   Group     4 (       Backbone) has   795 elements
#   Group     5 (      MainChain) has  1061 elements
#   Group     6 (   MainChain+Cb) has  1302 elements
#   Group     7 (    MainChain+H) has  1311 elements
#   Group     8 (      SideChain) has  2521 elements
#   Group     9 (    SideChain-H) has   892 elements
#   Group    10 (    Prot-Masses) has  3832 elements
#   Group    11 (    non-Protein) has 29412 elements
#   Group    12 (          Other) has    90 elements
#   Group    13 (            UNK) has    90 elements
#   Group    14 (             NA) has    30 elements
#   Group    15 (             CL) has    36 elements
#   Group    16 (          Water) has 29256 elements
#   Group    17 (            SOL) has 29256 elements
#   Group    18 (      non-Water) has  3988 elements
#   Group    19 (            Ion) has    66 elements
#   Group    20 (            UNK) has    90 elements
#   Group    21 (             NA) has    30 elements
#   Group    22 (             CL) has    36 elements
#   Group    23 ( Water_and_ions) has 29322 elements
#   Group    24 (complex_Protein_UNK) has  3922 elements
#   Group    25 (ligand_UNK_&_!H*) has    56 elements
#
#   del 0-25                # no way to del by name
#   keep 25                 # no way of keep by name
#   name 25 ligand          # no way of sel by name
