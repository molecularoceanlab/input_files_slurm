#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
sys.path.append("templates/plumed/")
import read_plumed as ref

# === ARGUMENTS  ===

parser = argparse.ArgumentParser(description="change dihedrals range")
parser.add_argument("--gauche_range", type=float, nargs=2, default=[60, 100],help="set gauche limits as four floats: --gauche_range -80 -60 60 80")
parser.add_argument("--trans_range",  type=float, nargs=2, default=[160, 180],help="set trans limits as four floats: --trans_range -180 -160 160 180")
args = parser.parse_args()

# === PARAMETERS ===
base_path = "2_md/4_md"
n_simulations = 200
gauche_range = args.gauche_range
trans_range  = args.trans_range

# === FUNCTIONS ===
def read_torsions(colvar):
    torsions = np.concatenate((np.degrees(colvar['t1']), np.degrees(colvar['t2']), np.degrees(colvar['t3'])), axis=None)
    return torsions

def classify_angles(angles, gauche_thresh, trans_thresh):
    gauche_count = sum(gauche_thresh[0] <= abs(a) <= gauche_thresh[1] for a in angles)
    trans_count = sum(trans_thresh[0] <= abs(a) <= trans_thresh[1] for a in angles)
    return trans_count, gauche_count

def parse_plumed_wall_params(filepath):
    at_value = None
    kappa_value = None
    with open(filepath, 'r') as f:
        for line in f:
            if 'LOWER_WALLS' in line and 'ARG=d1' in line:
                parts = line.strip().split()
                for part in parts:
                    if part.startswith("AT="):
                        at_value = float(part.split("=")[1])
                    elif part.startswith("KAPPA="):
                        kappa_value = float(part.split("=")[1])
    return at_value, kappa_value

## === MAIN ===
print(f"{gauche_range=}")
print(f"{trans_range=}")
print(f"syst\tdist_lw\tdist_av\t#count\t#trans\t#gauche\t   ratio(t:g)\tbias_av\tforc_lw\tforc_av")

for i in range(0, n_simulations):
    syst = str(i).zfill(3)
    colvar_path = f'{base_path}/md_{syst}/COLVAR'
    plumed_path = os.path.join(base_path, f"md_{syst}", f"plumed_{syst}.dat")

    # Skip missing COLVAR files
    if not os.path.exists(colvar_path):
        #print(f"{syst}\t-- MISSING COLVAR, skipped --")
        continue

    colvar = ref.load_plumed(colvar_path)
    tot = len(colvar["time"])
    dw_av = round(np.mean(colvar["d1"]), 1)

    bw_av = round(np.mean(colvar["lwall.bias"]), 1)
    fw_av = round(np.mean(colvar["lwall.force2"]), 1)

    torsions = read_torsions(colvar)
    trans_count, gauche_count = classify_angles(torsions, gauche_range, trans_range)
    counts = trans_count + gauche_count
    ratio_t = round(100 * trans_count / counts, 1)
    ratio_g = round(100 * gauche_count / counts, 1)

    at_val, kappa_val = parse_plumed_wall_params(plumed_path)

    print(f"{syst}\t{at_val}\t{dw_av}\t{counts}\t{trans_count}\t{gauche_count}\t{ratio_t}\t{ratio_g}\t{bw_av}\t{kappa_val}\t{fw_av}")

### === MAIN ===
#print(f"{gauche_range=}")
#print(f"{trans_range=}")
#print(f"syst\tdist_lw\tdist_av\t#count\t#trans\t#gauche\t   ratio(t:g)\tbias_av\tforc_lw\tforc_av")
#for i in range(0,n_simulations,5):
#    syst = str(i).zfill(3)
#    colvar = ref.load_plumed(f'{base_path}/md_{syst}/COLVAR')
#    tot = len(colvar["time"]) #
#    dw_av = round(np.mean(colvar["d1"]),1)
#    # extract from crys dimer simulations
#    #if i == 0:
#    #    bw_av = round(np.mean(colvar["lwall1.bias"]),1)
#    #    fw_av = round(np.mean(colvar["lwall1.force2"]),1)
#    #else:
#    #    bw_av = round(np.mean(colvar["lwall.bias"]),1)
#    #    fw_av = round(np.mean(colvar["lwall.force2"]),1)
#    # new simulations 00, 20-23
#    bw_av = round(np.mean(colvar["lwall.bias"]),1)
#    fw_av = round(np.mean(colvar["lwall.force2"]),1)
#    torsions = read_torsions(colvar)
#    tot_ts = len(torsions)
#    trans_count, gauche_count = classify_angles(torsions, gauche_range, trans_range)
#    counts = trans_count+gauche_count
#    ratio_t = round(100* trans_count/counts,1)
#    ratio_g = round(100*gauche_count/counts,1)
#
#    plumed_path = os.path.join(base_path,f"md_{syst}",f"plumed_{syst}.dat")
#    at_val,kappa_val = parse_plumed_wall_params(plumed_path)
#
#    print(f"{syst}\t{at_val}\t{dw_av}\t{counts}\t{trans_count}\t{gauche_count}\t{ratio_t}\t{ratio_g}\t{bw_av}\t{kappa_val}\t{fw_av}")
