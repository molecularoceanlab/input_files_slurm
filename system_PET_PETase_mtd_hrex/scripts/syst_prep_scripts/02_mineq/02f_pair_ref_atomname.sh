#!/usr/bin/env bash

#   DESCRIPTION
#   after pairing atom coords from pymol alignment - see scripts/02_mineq/02e_pair_ref_coords.py
#   using xray ref 5xh3 CA to align the protein and extract relative coords to the active site of the ligand towards target protein
#   manually match atom names of target xray ligand aligned and 4MHET atoms to be pulled at xray position to bind active site close to experimental evidence
#   extract pdb references for the CA and the ligand coords to rmsd during pulling and equilibrium
#   it creates a fake coordinates file where the atoms of the proteins CA make the alignment for the protein and the atoms from the selected ring atoms from ligand 4MHET are overwritten with coordinates from xray 5xh3 ligand.
#   this fake coords file (pdb) will serve as target to minimize rmsd during pulling and forse 4MHET towards the experimental binding mode
#	for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; echo $syst; ls; ../../../scripts/02_mineq/02f_pair_ref_atomname.sh $syst; ls ; cd ../../../; fi; done

syst=$1
bb='CA'      # align on CA instead of whole backbone

# filter CA coordinates for alignment
grep $bb eq.pdb > ca_coord.pdb

# copy to new structure where to attach xray ref ligand coordinates from 5hx3
cp ca_coord.pdb refcoord.pdb

# empty lig coords file to avoide appending
cat /dev/null > ligcoord.pdb

for pair in "O3 O02" "O4 O04" "C12 C06" "C13 C07" "C15 C15" "C16 C16" "O7 O10" "O8 O11" "O14 O14"; do

    set -- $pair

    idx=$1 # index
    crd=$2 # coord

    # clean file to append

    awk -v idx="$idx" -v crd="$crd" '
        FNR==NR {  # Process first file (eq.pdb)
            if ($1 == "ATOM" && $3 == idx) {
                printf("%-6s%1s%4d%2s%-3s%1s%3s%1s%1s%1s%3d%5s",$1,"",$2,"",$3,"",$4,"",$5,"",$6,"")
            }
            next
        }

        {  # Process second file (ligxr.pdb)
            if ($1 == "HETATM" && $3 == crd) {
                printf("%7.3f%1s%7.3f%1s%7.3f%1s\n",$7,"",$8,"",$9,"")
            }
        }
    ' eq.pdb ligxr.pdb | awk '{print $0, "0.00  1.00"}' >> ligcoord.pdb

done

#   sed -i 's/^ATOM  /HETATM/' ligcoord.pdb
#   echo -e "TER" >> refcoord.pdb
cat ligcoord.pdb >> refcoord.pdb
# not TER not HETATM for ligand
# plumed DRMS needs one sets of atoms to calculate rmsd

rm *.cif


