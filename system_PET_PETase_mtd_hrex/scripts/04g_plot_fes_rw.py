#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
from glob import glob
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import numpy as np
import os
import re
from scipy.stats import gaussian_kde

def load_fes(file_path):
    try:
        data = np.genfromtxt(file_path, comments="#")
        return data[:, 0], data[:, 1] - np.min(data[:, 1])
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None, None

def load_weights(file_path, kbt=2.494339):
    try:
        data = np.genfromtxt(file_path, comments="#")
        x = data[:, 0]
        y = -kbt * np.log(np.maximum(data[:, 1], 1e-12))
        return x, y
    except Exception as e:
        print(f"Error reading weights {file_path}: {e}")
        return None, None

def smooth_kde(x, y, bins=300):
    grid = np.linspace(np.min(x), np.max(x), bins)
    kde = gaussian_kde(x, weights=np.exp(-y / 2.494339))
    smoothed = kde(grid)
    smoothed = -2.494339 * np.log(smoothed / np.max(smoothed))
    return grid, smoothed

parser = argparse.ArgumentParser(description="FES plotter with compare mode")
parser.add_argument("--ligs", type=str, default="amor crys")
parser.add_argument("--cvs", type=str, default="h0 h1 s0 d0 x0 x1")
parser.add_argument("--exp", required=True)
parser.add_argument("--syst", default="6eqe_2")
parser.add_argument("--rep", default=0, type=int)
parser.add_argument("--fes", default="all", choices=["all", "sumhills", "reweight", "manual_reweight", "stride"])
parser.add_argument("--stride", default=2500, type=int)
parser.add_argument("--compare", action="store_true", help="Compare amor and crys in one plot")
parser.add_argument("--xlim", default='0,1.2', type=str, help="Set x-axis limits, e.g. 0,1.2")
parser.add_argument("--ylim", default='0,50', type=str, help="Set y-axis limits, e.g. 0,50")
parser.add_argument("--output_dir", default="figures")
parser.add_argument("--show", action="store_true")
parser.add_argument("--save", action="store_true")

args = parser.parse_args()

ligs = args.ligs.split()
cvs = args.cvs.split()
colors = {'amor': 'tab:blue', 'crys': 'tab:orange'}
use_rep = args.exp.startswith("hrex")
rep_path = f"/r{args.rep}" if use_rep else ""

# Parse zoom limits if provided
if args.xlim:
    try:
        xmin, xmax = map(float, args.xlim.split(","))
    except:
        print("Invalid --xlim format. Use: --xlim 0,1.2")

if args.ylim:
    try:
        ymin, ymax = map(float, args.ylim.split(","))
    except:
        print("Invalid --ylim format. Use: --ylim 0,50")

for cv in cvs:
    # STRIDE
    if args.fes == "stride":
        for lig in ligs:
            stride_dir = f"{lig}/{args.exp}{rep_path}/s{args.stride}"
            prefix = f"s{cv}"

            def numeric_sort_key(path):
                match = re.search(rf"{prefix}_(\d+)\.dat$", os.path.basename(path))
                return int(match.group(1)) if match else -1

            stride_files = sorted(glob(f"{stride_dir}/{prefix}_*.dat"), key=numeric_sort_key)
            if not stride_files:
                print(f"No stride files found for {lig} {cv}")
                continue

            cmap = cm.get_cmap("Blues") if lig == "amor" else cm.get_cmap("Oranges")
            shades = cmap(np.linspace(0.0, 1.0, len(stride_files)))

            outdir = f"{args.output_dir}/{args.syst}/{args.exp}/stride"
            if use_rep:
                outdir += f"/r{args.rep}"
            os.makedirs(outdir, exist_ok=True)
            outfile = f"{outdir}/{lig}_{cv}_stride.png"

            plt.figure(figsize=(16, 9), dpi=300)
            for i, path in enumerate(stride_files):
                x, y = load_fes(path)
                if x is None or y is None:
                    continue
                plt.plot(x, y, label=f"stride_{i}", color=shades[i], linewidth=2, alpha=0.8)

            plt.xlabel(f"{cv} (nm)", size=50)
            plt.ylabel("Free Energy (kJ/mol)", size=50)
            plt.title(f"FES: {lig} {cv} - {args.exp}", size=70)
            plt.xlim(xmin, xmax)
            plt.ylim(ymin, ymax)
            plt.tick_params(axis='both', labelsize=50, length=10, width=2)

            if args.save:
                plt.savefig(outfile, bbox_inches='tight')
                print(f"Saved plot to {outfile}")
            if args.show:
                plt.show()
            plt.close()
        continue

    # COMPARE MODE
    if args.compare:
        plt.figure(figsize=(16, 9), dpi=300)
        for lig in ligs:
            base = f"{lig}/{args.exp}{rep_path}"

            if args.fes in ["all", "sumhills"]:
                path = f"{base}/s{cv}.dat"
                if os.path.exists(path):
                    x, y = load_fes(path)
                    if x is not None:
                        plt.plot(x, y, label=f"sumhills {lig}", color=colors[lig], linewidth=3, alpha=0.8)

            if args.fes in ["all", "reweight"]:
                path = f"{base}/f{cv}.dat"
                if os.path.exists(path):
                    x, y = load_fes(path)
                    if x is not None:
                        plt.plot(x, y, label=f"reweight {lig}", color=colors[lig], linestyle='--', linewidth=2)

            if args.fes in ["all", "manual_reweight"]:
                path = f"{base}/{cv}.weight"
                if os.path.exists(path):
                    x, y = load_weights(path)
                    if x is not None:
                        xk, yk = smooth_kde(x, y)
                        plt.plot(xk, yk, label=f"manual KDE {lig}", color=colors[lig], linestyle=":", linewidth=2.5)

        outdir = f"{args.output_dir}/{args.syst}/{args.exp}/compare"
        if use_rep:
            outdir += f"/r{args.rep}"
        os.makedirs(outdir, exist_ok=True)
        outfile = f"{outdir}/{cv}_{args.fes}_compare.png"

        plt.xlabel(f"{cv} (nm)", size=50)
        plt.ylabel("Free Energy (kJ/mol)", size=50)
        plt.title(f"FES compare: {cv} - {args.exp}", size=70)
        plt.xlim(xmin, xmax)
        plt.ylim(ymin, ymax)
        plt.tick_params(axis='both', labelsize=50, length=10, width=2)
        plt.legend(fontsize=20)

        if args.save:
            plt.savefig(outfile, bbox_inches='tight')
            print(f"Saved comparison to {outfile}")
        if args.show:
            plt.show()
        plt.close()
        continue

    # Normal (individual) plots per ligand
    for lig in ligs:
        base = f"{lig}/{args.exp}{rep_path}"
        plt.figure(figsize=(16, 9), dpi=300)

        if args.fes in ["all", "sumhills"]:
            path = f"{base}/s{cv}.dat"
            if os.path.exists(path):
                x, y = load_fes(path)
                if x is not None:
                    plt.plot(x, y, label="sumhills", color=colors[lig], linewidth=3, alpha=0.8)

        if args.fes in ["all", "reweight"]:
            path = f"{base}/f{cv}.dat"
            if os.path.exists(path):
                x, y = load_fes(path)
                if x is not None:
                    plt.plot(x, y, label="reweight", color=colors[lig], linestyle='--', linewidth=2)

        if args.fes in ["all", "manual_reweight"]:
            path = f"{base}/{cv}.weight"
            if os.path.exists(path):
                x, y = load_weights(path)
                if x is not None:
                    xk, yk = smooth_kde(x, y)
                    plt.plot(xk, yk, label="manual KDE", color=colors[lig], linestyle=":", linewidth=2.5)

        outdir = f"{args.output_dir}/{args.syst}/{args.exp}/fes"
        if use_rep:
            outdir += f"/r{args.rep}"
        os.makedirs(outdir, exist_ok=True)
        outfile = f"{outdir}/{lig}_{cv}_{args.fes}.png"

        plt.xlabel(f"{cv} (nm)", size=50)
        plt.ylabel("Free Energy (kJ/mol)", size=50)
        plt.title(f"FES: {lig} {cv} - {args.exp}", size=70)
        plt.xlim(0, 1.2)
        plt.ylim(0, 50)
        plt.tick_params(axis='both', labelsize=50, length=10, width=2)
        plt.legend(fontsize=20)

        if args.save:
            plt.savefig(outfile, bbox_inches='tight')
            print(f"Saved plot to {outfile}")
        if args.show:
            plt.show()
        plt.close()

