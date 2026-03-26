#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
import os

def load_weights(filepath, kbt=2.494339):
    try:
        data = np.genfromtxt(filepath, comments="#")
        x = data[:, 0]
        w = np.maximum(data[:, 1], 1e-12)
        fes = -kbt * np.log(w / np.max(w))  # normalized
        return x, fes
    except Exception as e:
        print(f"Error loading {filepath}: {e}")
        return None, None

def smooth_fes(x, fes, bins=300):
    grid = np.linspace(np.min(x), np.max(x), bins)
    kde = gaussian_kde(x, weights=np.exp(-fes / 2.494339))
    smoothed = kde(grid)
    smoothed = -2.494339 * np.log(smoothed / np.max(smoothed))
    return grid, smoothed

# Args
parser = argparse.ArgumentParser(description="Plot FES from different time windows")
parser.add_argument("--cv", required=True, help="Collective variable (e.g. d0)")
parser.add_argument("--windows", required=True, help="Comma-separated list like 0-500,0-1000,...")
parser.add_argument("--kbt", type=float, default=2.494339)
parser.add_argument("--output_dir", default="figures")
parser.add_argument("--syst", default="6eqe_2")
parser.add_argument("--lig", default="amor")
parser.add_argument("--exp", default="hrex_mtd")
parser.add_argument("--rep", default="r0")
parser.add_argument("--save", action="store_true")
parser.add_argument("--show", action="store_true")
args = parser.parse_args()

windows = args.windows.split(",")
colors = plt.cm.Blues(np.linspace(0.2, 0.95, len(windows)))
exp = args.exp
rep = args.rep
cv = args.cv
lig = args.lig

plt.figure(figsize=(16, 9), dpi=300)
for i, win in enumerate(windows):
    try:
        start, end = win.split("-")
        start = int(start)
        end = int(end)
    except ValueError:
        print(f"Invalid window format: {win}")
        continue

    filename = f"{lig}/{exp}/{rep}/{cv}_{start}_{end}.weight"
    if not os.path.exists(filename):
        print(f"Missing: {filename}")
        continue

    x, fes = load_weights(filename, kbt=args.kbt)
    if x is None:
        continue

    xk, yk = smooth_fes(x, fes)
    label = f"{cv}\t{start}\t{end}"
    plt.plot(xk, yk, label=label, color=colors[i], linewidth=2)

plt.xlabel(f"{cv} (nm)", size=50)
plt.ylabel("Free Energy (kJ/mol)", size=50)
plt.title(f"FES from different windows ({cv})", size=70)
plt.xlim(0, 1.2)
plt.ylim(0, 50)
plt.tick_params(axis='both', labelsize=50, length=10, width=2)
plt.legend(title="Window (ns)", fontsize=16, title_fontsize=18)

outdir = f"{args.output_dir}/{args.syst}/{args.exp}/rw/{args.rep}"
os.makedirs(outdir, exist_ok=True)
outfile = f"{outdir}/{cv}_window_fes.png"

if args.save:
    plt.savefig(outfile, bbox_inches='tight')
    print(f"Saved plot to {outfile}")
if args.show:
    plt.show()
plt.close()

