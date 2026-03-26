#!/usr/bin/env python3
# -*- coding: UTF8 -*-

#   DESCRIPTION
#   
#   the scripts prepare the protein pdb as prot.pdb
#   fetch the protein from the pdb ID and clean anisou and multiple occupancy
#   if retromutation is needed, it mutate to the most poputated mutant
#   opens as pymol to visualize the protein and saves the prot.pdb
#   it works from the 01_syst_prep folder
#   ../../../scripts/01_sysprep/01a_clean_structure.py "6eqe"
#   ../../../scripts/01_sysprep/01a_clean_structure.py "7nei" 131 "SER" "SER" | doble annotation of serine in xray

import re
import sys
import os
import argparse
import pymol
from pymol import cmd

if len(sys.argv) > 1:
    prot = sys.argv[1]
else:
    print('6eqe')
    prot = None

if len(sys.argv) > 3:
    residue_number = int(sys.argv[2])
    current_residue = sys.argv[3]
    mutated_residue = sys.argv[4]
    mut = [ residue_number, current_residue, mutated_residue ]
else:
    print('Usage: script.py <protein_id> <num_res> <wt_res_orig> <mut_res_target>')
    print('Usage: ../../../scripts/01_sysprep/01a_clean_structure.py "6ths" 165 "ALA" "SER"')	# from ALA to SER on res n 165 for pdb 6ths
    mut = None

print(prot)
print(mut)
print(type(mut))

aa = {
    'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
    'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
    'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
    'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'
}

# Checking if the dictionary is correct
#for k, v in aa.items():
#    print(f"{k}: {v}")

# protein pdbID, catalytic residues SER, ASP, HIS, PRO where the Nterm cut for rmsd and pca calculations, last aa, s-s bonds pairs, oxyanion hole N MET~131/161, N TYR~60/87, active site trp pairs
# !!! 4eb0 errors !!!
#    pdbid          name                 ser, his, asp, pro, nterm,   s-s1,       s-s2,     met, tyr,   trp1, trp2
triad = {                                             
    "5xh3": ["IsPETase_R103G/S131A",    [131, 208, 177],  20, 261, [244, 260], [174, 210], [" ", " "], [" ", " "]],
    "6eqe": ["IsPETase_wt",             [160, 237, 206],  49, " ", [273, 289], [203, 239], [161,  87], [159, 185]],
    "6ky5": ["DURAPET",                 [160, 237, 206],  49, 292, [273, 289], [203, 239], [" ", " "], [" ", " "]],
    "4cg1": ["TfCut",                   [130, 208, 176],  21, 261, [241, 259], [" ", " "], [" ", " "], [" ", " "]],
    "7nei": ["PHL7",                    [131, 209, 177],  22, 259, [242, 257], [" ", " "], [" ", " "], [" ", " "]],
    "4eb0": ["LCC",                     [165, 242, 210], " ", " ", [" ", " "], [" ", " "], [166,  95], [" ", 190]],
    "6ths": ["LCC-S165A",               [165, 242, 210], " ", " ", [" ", " "], [" ", " "], [166,  95], [" ", 190]],
    "6tht": ["LCC-ICCG-S165A",          [165, 242, 210], " ", " ", [" ", " "], [" ", " "], [166,  95], [" ", 190]]
}
   #"4eb0": ["LCC",                     [130, 207, 175],  20, 258, [240, 257], [" ", " "], [" ", " "], [" ", " "]]

print(triad[prot][1])
print(f'{triad[prot][1]}')

# Launch PyMOL
pymol.finish_launching()

# Define input and output file paths
input_pdb = 'proc_prot.pdb'
output_pdb = 'prot.pdb'

# download prot PDB and clean
cmd.fetch(f'{prot}')
# save pdb for prot into dir
cmd.save(input_pdb,selection=f'{prot}')

# Open input and output files
with open(input_pdb, 'r') as infile, open(output_pdb, 'w') as outfile:
    for line in infile:
        # Check if the line starts with 'ANISOU'
        if not line.startswith('ANISOU'):
            # Check for ATOM or HETATM lines
            if line.startswith("ATOM") or line.startswith("HETATM"):
                alt_loc = line[16]  # Alternate location indicator is at column 17
                if alt_loc == ' ' or alt_loc == 'A':
                    outfile.write(line)
            else:
                outfile.write(line)

# Remove the input PDB file after processing
os.remove(input_pdb)
os.remove(f'{prot}.cif')

# edit on pymol
cmd.delete(f'{prot}')
cmd.load('prot.pdb',prot)
cmd.remove('solvent or inorganic or organic')
cmd.remove('not chain A')
act_site = f'resi {triad[prot][1][0]}+{triad[prot][1][1]}+{triad[prot][1][2]}'
cmd.select('AS',act_site)
cmd.select('BS',f'byres {act_site} around 3')
cmd.orient('BS')
cmd.zoom('*')
cmd.show('sticks',act_site)
cmd.color('green',act_site)

#if mut is not None:
if type(mut) is list:
    print('entering the loop')
    # 6eqe for mutant S238A ACScatal2022Guo
    #mut = [ 238, "S", "A"]

    # mutations
    #cmd.select('mutS238A',selection=f'resi {mut[1]}')
    cmd.select(f'mut{mut[1]}{mut[0]}{mut[2]}',selection=f'resi {mut[0]}')
    cmd.show('sticks',selection=f'mut{mut[1]}{mut[0]}{mut[2]}')
    cmd.select('reg',selection=f'byres resi {mut[0]} around 3')
    cmd.orient(f'mut{mut[1]}{mut[0]}{mut[2]} or reg')
    cmd.create(f'mut_{prot}',selection=f'{prot}')
    # mutate wizard
    cmd.wizard("mutagenesis")
    cmd.do("refresh_wizard")
    # Mutate residue
    cmd.get_wizard().do_select(f'/mut_{prot}///{mut[0]}') # res_num
    #cmd.get_wizard().set_mode("ALA") # res_type
    cmd.get_wizard().set_mode(f'{mut[2]}') # res_type
    # Select the rotamer with the lowest energy (1)
    cmd.frame(1)
    # Apply the mutation
    cmd.get_wizard().apply()
    # close wizard
    cmd.set_wizard("done")

cmd.color('grey90',selection=f'{prot} and elem C* and not {act_site}')
cmd.color('atomic',selection='all and not elem C*')
cmd.deselect()

# clear hydrogens. leave terms as they are
cmd.remove('hydrogens')
# save pdb for prot into dir
cmd.save(output_pdb,selection=f'{prot}')
#if mut is not None:
if type(mut) is list:
    cmd.save(output_pdb,selection=f'mut_{prot}')
