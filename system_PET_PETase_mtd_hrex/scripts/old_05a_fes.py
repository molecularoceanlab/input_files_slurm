#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from matplotlib import cm
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.colors import ListedColormap
from matplotlib.colors import ListedColormap, to_rgb
import matplotlib.pyplot as plt
import argparse
import os
from scipy.stats import gaussian_kde

kbt  = 2.494339

def gradient_cmap(hex_color, n=256):
    base = np.array(to_rgb(hex_color))
    white = np.ones(3)
    colors = [base + (white - base) * (i / (n - 1)) for i in range(n)]
    return ListedColormap(colors)

def load_fes_1d(file):
    data = np.genfromtxt(file, comments="#")
    x, y = data[:, 0], data[:, 1]
    y -= np.min(y)
    return x, y

def load_weight_1d(file):
    data = np.genfromtxt(file, comments="#")
    x = data[:, 0]
    w = np.maximum(data[:, 1], 1e-12)
    return x, w

def load_fes_2d(file):
    data = []
    with open(file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            fields = line.split()
            if len(fields) < 3:
                continue
            x, y, z = float(fields[0]), float(fields[1]), fields[2]
            z = float(z) if z != 'inf' else np.nan
            data.append([x, y, z])
    data = np.array(data)

    x_vals = np.unique(data[:, 0])
    y_vals = np.unique(data[:, 1])
    z_grid = data[:, 2].reshape(len(x_vals), len(y_vals))
    z_grid -= np.nanmin(z_grid)  # Normalize to min = 0
    return x_vals, y_vals, z_grid

def smooth_kde(x, weight, bins=300):
    grid = np.linspace(np.min(x), np.max(x), bins)
    kde = gaussian_kde(x, weights=weight)
    pdf = kde(grid)
    fes = -kbt * np.log(np.maximum(pdf, 1e-20))
    fes -= np.min(fes)
    return grid, fes

def truncate_colormap(cmap, minval=0.2, maxval=0.9, n=256):
    return LinearSegmentedColormap.from_list(
        f"trunc({cmap.name},{minval:.2f},{maxval:.2f})",
        cmap(np.linspace(minval, maxval, n))
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lig", required=True, choices=["amor", "crys", "compare"])
    parser.add_argument("--var", required=True)
    parser.add_argument("--dim", required=True, choices=["1D", "2D"])
    parser.add_argument("--source", required=True, choices=["fes", "weight"], help="Select FES or weight input")
    parser.add_argument("--outdir", default="figures/6eqe_2/plots")
    parser.add_argument("--save", action="store_true")
    parser.add_argument("--show", action="store_true")
    parser.add_argument("--xlim", default="0.2,0.7", type=str)
    parser.add_argument("--ylim", default="0.0,30",  type=str)
    parser.add_argument("--yl2D", default="0.2,0.7", type=str)
    parser.add_argument("--zlim", default="0.0,30",  type=str, help="e.g. 0,40")
    parser.add_argument("--kde", action="store_true",help="(For weights) Apply KDE smoothing")
    parser.add_argument("--exp", default="hrex_mtd")
    parser.add_argument("--rep", default="0")
    parser.add_argument("--basepath", default=".")
    parser.add_argument("--cmap", default=None, help="Force custom hex colormap base")

    args = parser.parse_args()
    os.makedirs(args.outdir, exist_ok=True)

    colors = {"amor": "#008080", "crys": "#ff7f0e"}
    # Select base color by system
    base_color = "#008080" if args.lig == "amor" else "#ff7f0e" # --cmap "#d33682"  # magenta style
    cmap = gradient_cmap(base_color)
    cmap = truncate_colormap(cm.magma, 0.2, 0.95)

    ligands = ["amor", "crys"] if args.lig == "compare" else [args.lig]
    suff = ''

    if args.dim == "1D":
        fig, ax = plt.subplots(figsize=(6, 4))
        for lig in ligands:
            if args.source == "fes":
                fpath = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/fes/f{args.var}.dat"
                if not os.path.isfile(fpath):
                    print(f"[Warning] File not found: {fpath}")
                    continue
                x, y = load_fes_1d(fpath)
                plt.plot(x, y, label=f"{lig} FES", color=colors[lig])
                plt.xlabel(f"{args.var} (nm)")
                plt.ylabel("FES (kJ/mol)")
            elif args.source == "weight":
                fpath = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/weights/{args.var}.weight"
                
                if not os.path.isfile(fpath):
                    print(f"[Warning] File not found: {fpath}")
                    continue
                x, w = load_weight_1d(fpath)
                
                if args.kde:
                    suff = '_kde'
                    x_smooth, y_smooth = smooth_kde(x, w)
                    plt.plot(x_smooth, y_smooth, label=f"{lig} KDE-weight→FES", color=colors[lig], linestyle="solid")
                else:
                    fes = -kbt * np.log(w)
                    fes -= np.min(fes)
                    idx = np.argsort(x)
                    plt.plot(x[idx], fes[idx], label=f"{lig} raw-weight→FES", color=colors[lig], linestyle="solid")

                plt.xlabel(f"{args.var} (nm)")
                plt.ylabel("FES (kJ/mol)")

        #plt.legend()

    elif args.dim == "2D":
        fig, ax = plt.subplots() #figsize=(8, 6))
        for lig in ligands:
            if args.source == "fes":
                fpath = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/fes/f{args.var}.dat"
                if not os.path.isfile(fpath):
                    print(f"[Warning] File not found: {fpath}")
                    continue
                x, y, z = load_fes_2d(fpath)
                X, Y = np.meshgrid(y, x)
                ax.set_aspect(1/1)
                # Apply zmax mask
                zmin, zmax = map(float, args.zlim.split(","))
                z[z > zmax] = np.nan
                z[z < zmin] = np.nan
                z -= np.nanmin(z)  # re-normalize after masking

                cmap = truncate_colormap(cm.viridis, 0.0, 1.00)
                contour = ax.contourf(X, Y, z, levels=80, cmap=cmap, extend='neither')
                # Add contour lines every 5 kJ/mol
                line_levels = np.arange(zmin, zmax + 5, 5)
                ax.contour(X, Y, z, levels=line_levels, colors='white', linewidths=0.5)
                ax.set_xlabel(f"{args.var.split('_')[0]} (nm)")
                ax.set_ylabel(f"{args.var.split('_')[1]} (nm)")
                cbar = fig.colorbar(contour, ax=ax, location='right', pad=-0.5, shrink=0.70)
                cbar.set_label("FES (kJ/mol)")

    
            elif args.source == "weight":
                # Placeholder — will implement with 2D KDE
                pass

    if args.xlim:
        xmin, xmax = map(float, args.xlim.split(","))
        ax.set_xlim(xmin, xmax)
    if args.ylim:
        ymin, ymax = map(float, args.ylim.split(","))
        ax.set_ylim(ymin, ymax)
    if args.zlim and args.dim == "2D":
        ymin, ymax = map(float, args.yl2D.split(","))
        ax.set_ylim(ymin, ymax)
        zmin, zmax = map(float, args.zlim.split(","))
        contour.set_clim(zmin, zmax)
    
    plt.tight_layout()
    outbase = f"{args.lig}_{args.var}_{args.source}_{args.dim}{suff}"
    outname = f"{args.outdir}/{outbase}.png"

    if args.save:
        plt.savefig(outname, dpi=300, transparent=True)
        print(f"Saved: {outname}")
    if args.show:
        plt.show()

if __name__ == "__main__":
    main()

