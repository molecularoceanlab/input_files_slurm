#!/usr/bin/env python3
# -*- coding: UTF8 -*-

#   DESCRIPTION
#   
#   prepare reference structure (5xh3) from xray monomer for pulling on ref coords
#   works from systs/$syst/02_mineq/ folder
#   syst=7nei
#   ../../../scripts/02_mineq/02e_pair_ref.py $syst
#   cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02e_pair_ref.py $syst ; cd ../../../
#   for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq; ../../../scripts/02_mineq/02e_pair_ref.py $syst ; cd ../../../; fi; done

import re
import sys
import os
import argparse
import pymol
from pymol import cmd

if len(sys.argv) > 1:
    prot = sys.argv[1]
    print('xray monomer coordinate pairing with complex for pulling')
else:
    print('Usage: ../../../scripts/02_mineq/02d_pair_ref.py from systs/$syst/02_mineq/ folder')

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

ref = '5xh3'
print(f'prot {prot} {triad[prot][1]}, xray ref {ref}')

# Launch PyMOL
pymol.finish_launching()

# not possible to align to the eq.gro, so use eq.pdb for last step
# get ref and align to eq, remove all not organic
last_pdb = 'eq' 
cmd.load(f'{last_pdb}.pdb',object=f'{prot}_{last_pdb}_last_pdb')
cmd.fetch(f'{ref}',name=f'{ref}_ref')
cmd.remove('solvent or inorganic')
cmd.extra_fit(f'{ref}_ref and name CA',f'{prot}_{last_pdb}_last_pdb and name CA')

# create coordinates for xray ligand in syst coordinates system
cmd.create(name='lig',selection=f'resname 856 and {ref}_ref')
cmd.save(f'ligxr.pdb',selection=f'lig')
#cmd.quit()
