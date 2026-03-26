#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import numpy as np
from matplotlib import cm
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, to_rgb
from matplotlib.colors import LinearSegmentedColormap
from scipy.stats import gaussian_kde
from scipy.ndimage import gaussian_filter
from scipy.ndimage import gaussian_filter1d

kbt  = 2.494339

# Sample 256-color gradient from RdPu
def custom_from_builtin(name="RdPu"):
    return cm.get_cmap(name, 256)  # or BuPu, magma, inferno, etc.

def reversed_rdpu(palette="RdPu"):
    base = cm.get_cmap("RdPu", 256)
    return ListedColormap(base(np.linspace(0.2, 1.0, 256))[::-1])  # reverse + truncate

def custom_teal_cmap():
    return LinearSegmentedColormap.from_list("teal_map", [
        (0.0, "#000000"),  # black
        (0.1, "#003333"),  # very dark teal
        (0.5, "#008080"),  # base teal
        (1.0, "#CCFFFF")   # light cyan
    ])

def custom_magenta_cmap():
    return LinearSegmentedColormap.from_list("magenta_map", [
        (0.0, "#000000"),
        (0.3, "#330033"),
        (0.6, "#800080"),
        (1.0, "#FFCCFF")
    ])

def custom_diverging_cmap():
    return LinearSegmentedColormap.from_list("div_map", [
        (0.0, "#0000AA"),  # deep blue
        (0.5, "#00FFFF"),  # cyan
        (1.0, "#FF66CC")   # pink
    ])

def custom_named_cmap():
    return LinearSegmentedColormap.from_list("custom_teal_magenta", [
        "midnightblue",  # dark blue
        "teal",
        "orchid",        # purplish
        "mistyrose"      # light pink
    ])

def preview_cmap(cmap):
    gradient = np.linspace(0, 1, 256).reshape(1, -1)
    plt.imshow(gradient, aspect='auto', cmap=cmap)
    plt.axis('off')
    plt.show()

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
#    z_grid = data[:, 2].reshape(len(x_vals), len(y_vals))
    z_grid = data[:, 2].reshape(len(x_vals), len(y_vals))
    z_grid -= np.nanmin(z_grid)
    return x_vals, y_vals, z_grid

def load_weight_2d(file):
    data = np.genfromtxt(file, comments="#")
    x, y, w = data[:, 0], data[:, 1], np.maximum(data[:, 2], 1e-12)
    fes = -kbt * np.log(w)
    fes -= np.min(fes)
    return x, y, fes

def smooth_kde(x, weight, bins=300):
    grid = np.linspace(np.min(x), np.max(x), bins)
    kde = gaussian_kde(x, weights=weight)
    pdf = kde(grid)
    fes = -kbt * np.log(np.maximum(pdf, 1e-20))
    fes -= np.min(fes)
    return grid, fes

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lig", required=True, choices=["amor", "crys", "compare"])
    parser.add_argument("--var", required=True)
    parser.add_argument("--dim", required=True, choices=["1D", "2D"])
    parser.add_argument("--source", required=True, choices=["fes", "weight"])
    parser.add_argument("--outdir", default="figures/plots")
    parser.add_argument("--save", action="store_true")
    parser.add_argument("--show", action="store_true")
    parser.add_argument("--xlim", default="0.2,0.7", type=str)
    parser.add_argument("--ylim", default="0.0,40", type=str)
    parser.add_argument("--yl2D", default="0.2,0.7", type=str)
    parser.add_argument("--zlim", default="0.0,40", type=str)
    parser.add_argument("--kde", action="store_true")
    parser.add_argument("--axisoff", action="store_true")
    parser.add_argument("--exp", default="hrex_mtd")
    parser.add_argument("--rep", default="0")
    parser.add_argument("--basepath", default=".")
    parser.add_argument("--cmap", default=None, help="Hex color override")

    args = parser.parse_args()
    os.makedirs(args.outdir, exist_ok=True)

    #colors = {"amor": "#008080", "crys": "#ff7f0e"}
    # Choose a color from your custom cmap
    colors = {"amor": custom_teal_cmap()(0.5), "crys": reversed_rdpu()(0.5)}
    ligands = ["amor", "crys"] if args.lig == "compare" else [args.lig]

    if args.dim == "1D":
        fig, ax = plt.subplots(figsize=(8, 4))
        #ax.set_aspect(2)
        for lig in ligands:
            base = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/"
            color = colors[lig]
            # Choose a color from your custom cmap
            if lig == "amor":
                base_color = custom_teal_cmap()(0.7)  # bright end
            elif lig == "crys":
                base_color = reversed_rdpu()(0.7)     # bright end
            if args.source == "fes":
                path = base + f"fes/f{args.var}.dat"
                if not os.path.isfile(path):
                    print(f"[Warning] File not found: {path}")
                    continue
                x, y = load_fes_1d(path)
                if args.kde:
                    yk = gaussian_filter1d(y, sigma=2)
                    ax.plot(x, yk, label=f"{lig} KDE-FES", color=color)
                else:
                    ax.plot(x, y, label=f"{lig} FES", color=color)
            elif args.source == "weight":
                path = base + f"weights/{args.var}.weight"
                print(path)
                if not os.path.isfile(path):
                    print(f"[Warning] File not found: {path}")
                    continue
                x, w = load_weight_1d(path)
                if args.kde:
                    xk, yk = smooth_kde(x, w)
                    ax.plot(xk, yk, label=f"{lig} KDE-weight→FES", color=color)
                else:
                    fes = -kbt * np.log(w)
                    fes -= np.min(fes)
                    ax.plot(np.sort(x), fes[np.argsort(x)], label=f"{lig} raw-weight→FES", color=color)
            ax.set_xlabel(f"{args.var} (nm)")
            ax.set_ylabel("FES (kJ/mol)")

    elif args.dim == "2D":
        fig, ax = plt.subplots()
        ax.set_aspect(1)
        zmin, zmax = map(float, args.zlim.split(","))
        for lig in ligands:
            base = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/"
            color = args.cmap or colors[lig]
            cmap = gradient_cmap(color)
            if lig == "amor":
                cmap = custom_teal_cmap()
                #cmap = custom_diverging_cmap()
            elif lig == "crys":
                #cmap = custom_magenta_cmap()
                #cmap = custom_from_builtin("BuPu")
                cmap = reversed_rdpu(palette="RdPu")
                #preview_cmap(custom_named_cmap())
            else:
                cmap = "magma"  # fallback

            if args.lig == "compare" and args.source == "fes":
                for lig in ["amor", "crys"]:
                    base = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/"
                    #color = colors[lig]
                    path = base + f"fes/f{args.var}.dat"
                    if not os.path.isfile(path):
                        print(f"[Warning] File not found: {path}")
                        continue
                    x, y, z = load_fes_2d(path)
                    z[z > zmax] = np.nan
                    z[z < zmin] = np.nan
                    z -= np.nanmin(z)
                    X, Y = np.meshgrid(x, y)

                    # Choose a color from your custom cmap
                    color = colors[lig]
                    if lig == "amor":
                        base_color = custom_teal_cmap()(0.6)  # bright end
                    elif lig == "crys":
                        base_color = reversed_rdpu()(0.6)     # bright end

                    #ax.contour(X, Y, z, levels=np.arange(zmin, zmax +10,10), colors=[base_color], linewidths=1.0, linestyles='solid', label=lig)
                    ax.contour(X, Y, z, levels=np.arange(zmin, zmax +10,10), colors=[color], linewidths=1.0, linestyles='solid', label=lig)
        
                ax.set_xlabel(f"{args.var.split('_')[0]} (nm)")
                ax.set_ylabel(f"{args.var.split('_')[1]} (nm)")
                ax.set_xlim(*map(float, args.xlim.split(",")))
                ax.set_ylim(*map(float, args.yl2D.split(",")))
                plt.tight_layout()

            elif args.source == "fes":
                path = base + f"fes/f{args.var}.dat"
                if not os.path.isfile(path):
                    print(f"[Warning] File not found: {path}")
                    continue
                x, y, z = load_fes_2d(path)
                if args.kde:
                    z = gaussian_filter(z, sigma=1.0)
                z[z > zmax] = np.nan
                z[z < zmin] = np.nan
                z -= np.nanmin(z)
                #X, Y = np.meshgrid(y, x)
                X, Y = np.meshgrid(x, y)
                contour = ax.contourf(X, Y, z, levels=80, cmap=cmap, extend='neither')
                ax.contour(X, Y, z, levels=np.arange(zmin, zmax + 5, 5), colors='white', linewidths=0.5)
            elif args.source == "weight":
                path = base + f"weights/{args.var}_2D.weight"
                if not os.path.isfile(path):
                    print(f"[Warning] File not found: {path}")
                    continue
                x, y, fes = load_weight_2d(path)
                mask = (fes >= zmin) & (fes <= zmax)
                x, y, fes = x[mask], y[mask], fes[mask]
                X, Y, z = x, y, fes

            ax.set_xlabel(f"{args.var.split('_')[0]} (nm)")
            ax.set_ylabel(f"{args.var.split('_')[1]} (nm)")
            if args.lig != "compare":
                cbar = fig.colorbar(contour, ax=ax, location='right', shrink=0.7, pad=-0.50)
                cbar.set_label("FES (kJ/mol)")
                contour.set_clim(zmin, zmax)

    xmin, xmax = map(float, args.xlim.split(","))
    ax.set_xlim(xmin, xmax)
    ymin, ymax = map(float, args.ylim.split(",") if args.dim == "1D" else args.yl2D.split(","))
    ax.set_ylim(ymin, ymax)
    if args.zlim and args.dim == "2D":
        zmin, zmax = map(float, args.zlim.split(","))
        #contour.set_clim(zmin, zmax)

    plt.tight_layout()
    
    if args.axisoff:
        plt.axis('off')
    print(path)
    #suffix = "_2D" if args.dim == "2D" else ""
    outname = f"{args.outdir}/{args.lig}_{args.dim}/{args.lig}_{args.var}_{args.source}_{args.dim}.png"

    if args.save:
        plt.savefig(outname, dpi=300, transparent=True)
        print(f"Saved: {outname}")
    if args.show:
        plt.show()

if __name__ == "__main__":
    main()

