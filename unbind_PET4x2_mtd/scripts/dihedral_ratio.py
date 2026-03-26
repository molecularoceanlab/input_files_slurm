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
base_path = "torsions"
ligs = ['amor','crys']
gauche_range = args.gauche_range
trans_range  = args.trans_range

# === FUNCTIONS ===
def read_torsions(colvar):
    torsions_mol1 = np.concatenate((np.degrees(colvar['t1']), np.degrees(colvar['t2']), np.degrees(colvar['t3'])), axis=None)
    torsions_mol2 = np.concatenate((np.degrees(colvar['t4']), np.degrees(colvar['t5']), np.degrees(colvar['t6'])), axis=None)
    return torsions_mol1, torsions_mol2

def classify_angles(angles, gauche_thresh, trans_thresh):
    gauche_count = sum(gauche_thresh[0] <= abs(a) <= gauche_thresh[1] for a in angles)
    trans_count  = sum(trans_thresh[0]  <= abs(a) <= trans_thresh[1]  for a in angles)
    return trans_count, gauche_count

def parse_plumed_wall_params(filepath,cv='d1'):
    at_value = None
    kappa_value = None
    with open(filepath, 'r') as f:
        for line in f:
            if 'LOWER_WALLS' in line and f'ARG={cv}' in line:
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
for lig in ligs:
    colvar = ref.load_plumed(f'{lig}/{base_path}/torsions')
    tot = len(colvar["time"]) #
    
    dw_av_1 = round(np.mean(colvar["d1"]),1)
    bw_av_1 = round(np.mean(colvar["lwall1.bias"]),1)
    fw_av_1 = round(np.mean(colvar["lwall1.force2"]),1)
    
    dw_av_2 = round(np.mean(colvar["d2"]),1)
    bw_av_2 = round(np.mean(colvar["lwall2.bias"]),1)
    fw_av_2 = round(np.mean(colvar["lwall2.force2"]),1)

    dw_av_0 = round(np.mean(np.array([colvar["d1"],colvar["d2"]])),1)
    bw_av_0 = round(np.mean(np.array([colvar["lwall1.bias"],colvar["lwall2.bias"]])),1)
    fw_av_0 = round(np.mean(np.array([colvar["lwall1.force2"],colvar["lwall2.force2"]])),1)

    torsions1, torsions2 = read_torsions(colvar)
    torsions0 = np.concatenate((torsions1, torsions2), axis=None)

    trans0, gauche0 = classify_angles(torsions0, gauche_range, trans_range)
    trans1, gauche1 = classify_angles(torsions1, gauche_range, trans_range)
    trans2, gauche2 = classify_angles(torsions2, gauche_range, trans_range)

    count0 = trans0 + gauche0
    count1 = trans1 + gauche1
    count2 = trans2 + gauche2

    #ratio_0 = round(100 * trans0 / gauche0, 1)
    #ratio_1 = round(100 * trans1 / gauche1, 1)
    #ratio_2 = round(100 * trans2 / gauche2, 1)

    ratio_t0  = round(100 *  trans0 / count0, 1)
    ratio_g0  = round(100 * gauche0 / count0, 1)
    ratio_t1  = round(100 *  trans1 / count1, 1)
    ratio_g1  = round(100 * gauche1 / count1, 1)
    ratio_t2  = round(100 *  trans2 / count2, 1)
    ratio_g2  = round(100 * gauche2 / count2, 1)

    plumed_path = os.path.join(lig,base_path,f"torsions.dat")
    at_val_1,kappa_val_1 = parse_plumed_wall_params(plumed_path)
    at_val_2,kappa_val_2 = parse_plumed_wall_params(plumed_path,cv='d2')
    at_val_0 = np.mean(np.array([at_val_1,at_val_2]))
    kappa_val_0 = np.mean(np.array([kappa_val_1,kappa_val_2]))

    print(f"{lig}_0\t{at_val_0}\t{dw_av_0}\t{count0}\t{trans0}\t{gauche0}\t{ratio_t0}\t{ratio_g0}\t{bw_av_0}\t{kappa_val_0}\t{fw_av_0}")
    print(f"{lig}_1\t{at_val_1}\t{dw_av_1}\t{count1}\t{trans1}\t{gauche1}\t{ratio_t1}\t{ratio_g1}\t{bw_av_1}\t{kappa_val_1}\t{fw_av_1}")
    print(f"{lig}_2\t{at_val_2}\t{dw_av_2}\t{count2}\t{trans2}\t{gauche2}\t{ratio_t2}\t{ratio_g2}\t{bw_av_2}\t{kappa_val_2}\t{fw_av_2}")
