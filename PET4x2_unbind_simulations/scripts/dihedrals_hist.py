#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from scipy.ndimage import gaussian_filter1d
from scipy.stats import gaussian_kde
from scipy.stats import vonmises
sys.path.append("templates/plumed/")
import read_plumed as ref

# === ARGUMENTS  ===

parser = argparse.ArgumentParser(description="change dihedrals range")
parser.add_argument("--threshold",                           action="store_true",            help="add threshold lines")
parser.add_argument("--gauche_range", type=float, nargs=4,   default=[-100,  -60,  60, 100], help="set gauche limits as four floats: --gauche_range -80 -60 60 80")
parser.add_argument("--trans_range",  type=float, nargs=4,   default=[-180, -160, 160, 180], help="set trans limits as four floats: --trans_range -180 -160 160 180")
parser.add_argument("--ligs",                     nargs='+', default=["amor","crys"],        help="lig to show")
parser.add_argument("--save",                                action="store_true",            help="save or show")

args = parser.parse_args()

# === PARAMETERS ===
base_path = "torsions"
output_fig = "figures/bb"
ligs = args.ligs # ['amor','crys']
print(f'ligs:\t{ligs}')
if args.threshold:
    gauche_range = args.gauche_range
    trans_range  = args.trans_range

# === FUNCTIONS ===
def read_torsions(colvar,lig):
    return np.concatenate((
        np.degrees(colvar["t1"]),
        np.degrees(colvar["t2"]),
        np.degrees(colvar["t3"]),
        np.degrees(colvar["t4"]),
        np.degrees(colvar["t5"]),
        np.degrees(colvar["t6"])
    )), colvar["time"].shape

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

# === DATA COLLECTION ===
all_data = []
at_values = []
for i in ligs:
    colvar = ref.load_plumed(f'{i}/{base_path}/torsions_cv')
    torsions, time = read_torsions(colvar,lig=i)
    all_data.append(torsions)
    plumed_path = os.path.join(i,base_path,f"torsions.dat")
    at_value, _ = parse_plumed_wall_params(plumed_path)
    at_values.append(at_value)
    print(f'{i}:\t{at_value}\t{torsions.shape}\t{time}')

# === PLOT CONFIGURATION ===
deepteal = "#006d6d"
hotpink  = "#FF69B4"
wheat    = "#F5DEB3"
palette = {
    'amor': 'teal',         # '#017371'
    'crys': 'coral'         # '#FFA07A'
}
fig, ax = plt.subplots(figsize=(10, 6))

x_grid = np.linspace(-180, 180, 180)
x_radians = np.deg2rad(x_grid)

for i, torsions in enumerate(all_data):

    color = palette[ligs[i]]
    wall = f"{at_values[i]}"

    # --- Smoothed histogram (classic method)
    hist, bins = np.histogram(torsions, bins=180, range=(-180, 180), density=True)
    sigma=0.8 # the higher the smoother, the smaller the rawer
    smooth_hist = gaussian_filter1d(hist, sigma=sigma)
    bin_centers = 0.5 * (bins[:-1] + bins[1:])
    ax.plot(bin_centers, smooth_hist, color=color, linewidth=2, linestyle='-', label=f"{ligs[i]}")

    ax.hist(torsions, bins=500, alpha=0.2, density=True, color=color)

# === THRESHOLD LINES ===
if args.threshold:
    for thresh in gauche_range + trans_range:
        ax.axvline(thresh, linestyle="--", color="gray", linewidth=3)
        ax.text(thresh, ax.get_ylim()[1]*0.95, f"{thresh:.0f}°",
                rotation=90, verticalalignment='top', horizontalalignment='right',
                fontsize=20, color='gray')

ax.set_title("Torsional Angle Distribution (t1-6)", fontsize=14)
ax.set_xlabel("Torsion Angle (°)")
ax.set_ylabel("Density")
if args.threshold:
    ax.set_xlim(trans_range[0], trans_range[-1])
else:
    ax.set_xlim(-180,180)
ax.legend(loc='upper center', fontsize="x-small", ncol=1)

plt.tight_layout()

# === OUTPUT ===
if args.save:
    plt.savefig(f"{output_fig}/torsion_histogram.png", dpi=300)
    print(f"Plot saved to {output_fig}/torsion_histogram.png")
else:
    plt.show()

