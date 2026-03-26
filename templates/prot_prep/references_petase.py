#!/usr/bin/env python3
# -*- coding: UTF8 -*-

# PROTEIN GENERAL

# aa translation dictionary from 3 to 1 letter code

aa_3to1 = {
    'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
    'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
    'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
    'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'
}

# Create a reverse dictionary for one-letter to three-letter code
#aa_1to3 = {v: k for k, v in aa_3to1.items()}

aa_1to3 = {
    'C': 'CYS', 'D': 'ASP', 'S': 'SER', 'Q': 'GLN', 'K': 'LYS',
    'I': 'ILE', 'P': 'PRO', 'T': 'THR', 'F': 'PHE', 'N': 'ASN',
    'G': 'GLY', 'H': 'HIS', 'L': 'LEU', 'R': 'ARG', 'W': 'TRP',
    'A': 'ALA', 'V': 'VAL', 'E': 'GLU', 'Y': 'TYR', 'M': 'MET'
}

# Function to translate three-letter code to one-letter code
def translate_to_one_letter(three_letter_code):
    return aa_3to1.get(three_letter_code.upper(), 'Unknown')

# Function to translate one-letter code to three-letter code
def translate_to_three_letter(one_letter_code):
    return aa_1to3.get(one_letter_code.upper(), 'Unknown')

# PETASES

# petase proteins pdbID, catalytic residues SER, ASP, HIS, PRO where the Nterm cut for rmsd and pca calculations, last aa, s-s bonds pairs, oxyanion hole N MET~131/161, N TYR~60/87, active site trp pairs
#
#    pdbid          prot name            ser, his, asp, pro, nterm,   s-s1,       s-s2,     met,    tyr/phe,           trp1/his/ser,	trp2
triad = {
    "5xh3": ["IsPETase_R103G/S131A",    [131, 208, 177],  20, 261, [244, 260], [174, 210], [132, [ 58, "TYR" ]],       [[130, "TRP"], 156]],
    "6eqe": ["IsPETase_wt",             [160, 237, 206],  49, 293, [273, 289], [203, 239], [161, [ 87, "TYR" ]],       [[159, "TRP"], 185]],
    "6ky5": ["DURAPET",                 [160, 237, 206],  49, 292, [273, 289], [203, 239], [161, [ 87, "TYR" ]],       [[159, "HIS"], 185]],
    "4cg1": ["TfCut2",                  [130, 208, 176],  21, 261, [241, 259], [" ", " "], [131, [ 60, "PHE" ]],       [[129, "HIS"], 155]],
    "7nei": ["PHL7",                    [131, 209, 177],  22, 259, [242, 257], [" ", " "], [132, [ 63, "PHE" ]],       [[130, "HIS"], 156]],
    "4eb0": ["LCC",                     [130, 207, 175],  20, 258, [240, 257], [" ", " "], [131, [ 60, "TYR" ]],       [[129, "HIS"], 155]],
    "6ths": ["LCC-S165A",               [165, 242, 210],  55, 293, [275, 292], [" ", " "], [166, [ 95, "TYR" ]],       [[164, "HIS"], 190]],
    "6tht": ["LCC-ICCG-S165A",          [165, 242, 210],  55, 293, [275, 292], [238, 283], [166, [ 95, "TYR" ]],       [[164, "HIS"], 190]],
    "WT57": ["alpha57_WT",              [133, 210, 179],  22, 261, [246, 262], [176, 212], [134, [ 60, "TYR" ]],       [[132, "HIS"], 158]],
    "4G73": ["alpha73_4G",              [133, 210, 179],  22, 261, [246, 262], [176, 212], [134, [ 60, "TYR" ]],       [[132, "HIS"], 158]]
}

# mutations dictionary
mutations = {
    "5xh3":       [("R", 103, "G"), ("S", 131, "A")],
    "6eqe":       [],
    "6ky5":       [("S", 214, "H"),("I", 168, "R"),("W", 159, "H"),("S", 188, "Q"),("R", 280, "A"),("A", 180, "I"),("G", 165, "A"),("Q", 119, "Y"),("L", 117, "F"),("T", 140, "D")],
    "4cg1":       [],
    "7nei":       [],
    "7nei_F210T": [("F", 210, "T")],
    "4eb0":       [],
    "6ths":       [("S", 165, "A")],
    "6tht":       [("F", 243, "I"), ("D", 238, "C"), ("S", 283, "C"), ("Y", 127, "G"), ("S", 165, "A")],
    "WT57":       [],
    "4G73":       [("N",159,"D"),("T",261,"S"),("P",117,"L")]
}

def select_AS(prot):
    print(f'\n# show active site for {prot}:')
    print(f'ser his asp')
    print(triad[prot][1])
    aa_list = triad[prot][1]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_OX(prot):
    print(f'\n# show oxyanion hole for {prot}:')
    print(f'met {triad[prot][6][1][1].lower()}') # 'met tyr/phe'
    print(triad[prot][6])
    aa_list = [triad[prot][6][0],triad[prot][6][1][0]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_TRP(prot):
    print(f'\n# show trp or his pi-stack for {prot}:')
    print(f'{triad[prot][7][0][1].lower()} trp') # 'trp/his trp'
    print(triad[prot][7])
    aa_list = [triad[prot][7][1],triad[prot][7][0][0]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_CYS(prot):
    print(f'\n# show cys s-s bridge for {prot}:')
    print(f's-s1 s-s2 if present') # 'cys-cys'
    print(triad[prot][4],triad[prot][5])
    aa_list = [triad[prot][4][0],triad[prot][4][1],triad[prot][5][0],triad[prot][5][1]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

# PET LIGAND 4units

# lig 4MHET designed by fco

# Aromatic rings
ring1 = ["C" + str(i) for i in range(1, 7)]
ring2 = ["C" + str(i) for i in range(11, 17)]
ring3 = ["C" + str(i) for i in range(21, 27)]
ring4 = ["C" + str(i) for i in range(31, 37)]

rings = {
    "ring1": ring1, "ring2": ring2, "ring3": ring3, "ring4": ring4,
}

# Ethylene glycols atom in order for torsion calculation
eg1 = [  "O2",  "C8",  "C9",  "O3"]
eg2 = [  "O8", "C20", "C38", "O14"]
eg3 = [ "O10", "C28", "C29", "O11"]

egs = {
    "eg1": eg1, "eg2": eg2, "eg3": eg3,
}

# C carbonyles
cos = {
    "co1": "C17", "co2": "C7", "co3": "C10", "co4": "C19","co5": "C37", "co6": "C27", "co7": "C30", "co8": "C39",
}

# O carbonyles
ocs = {
    "oc1": "O5", "oc2": "O1", "oc3": "O4", "oc4": "O7", "oc5": "O13", "oc6": "O9", "oc7": "O12", "oc8": "O15",
}

# atom name references for 4MHET, 4 units of PET with methyl endings

MHET4 = {
    'rings' : rings, 'egs' : egs, 'cos' : cos, 'ocs' : ocs
    }
