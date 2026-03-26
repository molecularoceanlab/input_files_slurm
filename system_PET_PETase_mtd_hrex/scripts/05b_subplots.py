#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.colors import ListedColormap
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable
from scipy.ndimage import gaussian_filter, gaussian_filter1d
import seaborn as sns

kbt = 2.494339 # scipy.boltzman?
pi  = np.pi

def load_fes_1d(file, is_angle=False):
    data = []
    with open(file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            x = float(parts[0])
            y = float(parts[1]) if parts[1] != "inf" else np.nan
            if is_angle:
                x *= 180 / pi
            data.append([x, y])
    #data = np.genfromtxt(file, comments="#")
    data = np.array(data)
    x, y = data[:, 0], data[:, 1]
    y -= np.nanmin(y)
    return x, y

def load_fes_2d(file, flip=False, angle_vars=[]):
    data = []
    with open(file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) < 3:
                continue
            x, y, z = float(parts[0]), float(parts[1]), float(parts[2]) if parts[2] != "inf" else np.nan
            if angle_vars:
                if angle_vars[0]:
                    x *= 180/pi
                if angle_vars[1]:
                    y *= 180/pi
            data.append([x, y, z])
    data = np.array(data)
    print(f"{data.shape}")
    x_vals = np.unique(data[:, 0])
    y_vals = np.unique(data[:, 1])


    x_vals = np.unique(data[:, 0])
    y_vals = np.unique(data[:, 1])

    nx = len(x_vals)
    ny = len(y_vals)
    expected = nx * ny
    actual = data.shape[0]

    if actual > expected:
        print(f"[Warning] Extra data points: trimming to fit {nx} x {ny} grid")
        data = data[:expected]
    elif actual < expected:
        raise ValueError(f"[Error] Not enough data points to form a {nx} x {ny} grid")

    z_grid = data[:, 2].reshape(ny, nx)  # (y, x) shape for meshgrid

    #if len(x_vals) * len(y_vals) != len(data):
    #    raise ValueError("Inconsistent grid: cannot reshape z values")
    #z_grid = data[:, 2].reshape(len(y_vals), len(x_vals))  # (y, x) shape for meshgrid
    #X, Y = np.meshgrid(x_vals, y_vals)                     # shape (y, x)
    if flip:
        z_grid = z_grid.T
        x_vals, y_vals = y_vals, x_vals  # flip axis for consistency
    #z_grid = z_grid.T if flip else z_grid
    #z_grid = data[:, 2].reshape(len(x_vals), len(y_vals)) # ← always (y, x)
    print(f"x: {x_vals.shape}, y: {y_vals.shape}, z: {z_grid.shape}")
    #if flip:
    #    x_vals, y_vals = y_vals, x_vals  # swap names
    #    z_grid = z_grid.T                # transpose matrix
    z_grid -= np.nanmin(z_grid)
    return x_vals, y_vals, z_grid

def discrete_cmap(base_cmap, zmin, zmax, step=5):
    """Create a ListedColormap with discrete colors every `step` kJ/mol."""
    n_bins = int((zmax - zmin) / step)
    colors = base_cmap(np.linspace(0, 1, n_bins))
    cmap = ListedColormap(colors)
    bounds = np.arange(zmin, zmax + step, step)
    norm = plt.Normalize(vmin=zmin, vmax=zmax)
    return cmap, bounds, norm

# Load a seaborn palette with as many colors as you want
palette = sns.color_palette("BuPu", n_colors=256)  # or "rocket", "flare", "mako", "crest", etc.

def sns_cmap(name, reverse=False):
    palette = sns.color_palette(name, n_colors=256)
    if reverse:
        palette = palette[::-1]
    return ListedColormap(palette)

# ["#c9e4ca","#87bba2","#55828b","#3b6064","#364958"] greengrey
# ["#7400b8","#6930c3","#5e60ce","#5390d9","#4ea8de","#48bfe3","#56cfe1","#64dfdf","#72efdd","#80ffdb"] sea
# ["#03045e","#023e8a","#0077b6","#0096c7","#00b4d8","#48cae4","#90e0ef","#ade8f4","#caf0f8"] blues
# ["#d9ed92","#b5e48c","#99d98c","#76c893","#52b69a","#34a0a4","#168aad","#1a759f","#1e6091","#184e77"] vanille teal
# ["#07beb8","#3dccc7","#68d8d6","#9ceaef","#c4fff9"] light teal
# ["#0b132b","#1c2541","#3a506b","#5bc0be","#6fffe9"] dark teal
# #0e9594, #127475 # middle teal 
# ["#006d77","#83c5be","#edf6f9","#ffd9da","#89023e"] purple white teal
# ["#bee9e8","#62b6cb","#1b4965","#cae9ff","#5fa8d3"] clear teal dark petrol pale cyan
#blend_cool = '#0b132b,#1c2541,#3a506b,#0e9594,#5bc0be,#07beb8,#3dccc7,#68d8d6,#9ceaef,#c4fff9'
# ["#f72585","#b5179e","#7209b7","#560bad","#480ca8","#3a0ca3","#3f37c9","#4361ee","#4895ef","#4cc9f0"] divergent hotpink purple cyan saturated
# "#f88379","#f7e7ce","#008080","#40e0d0","#bbc2cc"
blend_cool = '#a4243b,#f88379,#f7e7ce,#008080,#40e0d0,#bbc2cc'

def custom_teal_cmap(name=f'blend:{blend_cool}'):# crest, mako
    #return LinearSegmentedColormap.from_list("custom_teal", ["#003333", "#008080", "#CCFFFF"], N=256)
    return ListedColormap(sns.color_palette(name, n_colors=256).as_hex())#[::-1]) # reverse

# https://coolors.co/palettes/trending
# ["#590d22","#800f2f","#a4133c","#c9184a","#ff4d6d","#ff758f","#ff8fa3","#ffb3c1","#ffccd5","#fff0f3"] pink red
# ["#ffe0e9","#ffc2d4","#ff9ebb","#ff7aa2","#e05780","#b9375e","#8a2846","#602437","#522e38"] magenta pink
# ["#355070","#6d597a","#b56576","#e56b6f","#eaac8b"] grey pink
# ["#ffcdb2","#ffb4a2","#e5989b","#b5838d","#6d6875"] grey pink light
# ["#fd0363","#cc095d","#9c1057","#6b1650","#3b1d4a","#0a2344"]
# ["#f28266","#f17063","#ef5d60","#ee4f64","#ec4067","#d9376d","#c62d72","#b32478","#a01a7d"] 
# ["#fd0363","#cc095d","#9c1057","#6b1650","#3b1d4a","#0a2344"] dark hot pink
# ["#fff3e6","#fdbdc4","#fa87a1","#f8517f","#f51b5c"] light hot pink with vanilla
# ["#000000","#3d2645","#832161","#da4167","#f0eff4"] dark grey purple whiteblue
# ["#ffd9da","#ea638c","#89023e","#30343f","#1b2021"] dark grey to hot pink to rose
# ["#e27396","#ea9ab2","#efcfe3","#eaf2d7","#b3dee2"] dirty rose to dirty cyan pastel
# ["#7bdff2","#b2f7ef","#eff7f6","#f7d6e0","#f2b5d4"] pastel cyan white rose
# ["#ffa69e","#faf3dd","#b8f2e6","#aed9e0","#5e6472"] pastel grey medium to cyan to rose
# ["#edd9b4","#7d2f5e","#4c0c1d","#0d5b5f","#6dbab4"] 
# ["#2d00f7","#6a00f4","#8900f2","#a100f2","#b100e8","#bc00dd","#d100d1","#db00b6","#e500a4","#f20089"] divergent blue to hotpink saturated
# ["#6f2dbd","#a663cc","#b298dc","#b8d0eb","#b9faf8"] purple cyan medium saturation
# ["#64a6bd","#90a8c3","#ada7c9","#d7b9d5","#f4cae0"] pale teal rose grey
# ["#e27396","#ea9ab2","#efcfe3","#eaf2d7","#b3dee2"] pastel hotpink vanille cyan
# ["#fdc5f5","#f7aef8","#b388eb","#8093f1","#72ddf7"] light pink to purple to cyan
# ["#ffffff","#84dcc6","#a5ffd6","#ffa69e","#ff686b"] white green cyan orange salmon
# ["#ff69eb","#ff86c8","#ffa3a5","#ffbf81","#ffdc5e"] fucsia to yellow
# ["#64113f","#de4d86","#f29ca3","#f7cacd","#84e6f8"] bordeaux to cyan <<<<<<<< ok
# ["#ddfff7","#93e1d8","#ffa69e","#aa4465","#861657"] cyan to dark red
# ["#0e7c7b","#17bebb","#d4f4dd","#d62246","#4b1d3f"] dart teal to dark red
# #006d77, #83c5be, #edf6f9, #ffd9da, #89023e green white red desaturate dark
# ["#b7094c","#a01a58","#892b64","#723c70","#5c4d7d","#455e89","#2e6f95","#1780a1","#0091ad"] dark purple to dark green 
# #d81159 hotpink
blend_hot = '#0e7c7b,#17bebb,#d4f4dd,#d62246,#4b1d3f'
blend_hot = '#64113f,#de4d86,#f29ca3,#f7cacd,#4ba3c3,#175676' # '#4ecdc4,#0e7c7b'

def custom_magenta_cmap(name=f'blend:{blend_hot}'): # flare, rocket
    return ListedColormap(sns.color_palette(name, n_colors=256).as_hex()[::-1])

def reversed_rdpu():
    base = plt.cm.get_cmap("RdPu", 256)
    return ListedColormap(base(np.linspace(0.2, 1.0, 256))[::-1])

def merged_teal_rdpu():
    teal = custom_teal_cmap()(np.linspace(0, 1, 128))
    rdpu = reversed_rdpu()(np.linspace(0, 1, 128))
    merged = np.vstack([teal, rdpu])
    return ListedColormap(merged)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lig", default="compare", choices=["amor", "crys", "compare"])
    parser.add_argument("--var", default="h0,d0")
    parser.add_argument("--zlim", default="0,40")
    parser.add_argument("--xlim", default="0.2,1.0")
    parser.add_argument("--yl2D", default="0.2,1.0")
    parser.add_argument("--exp", default="hrex_mtd")
    parser.add_argument("--rep", default="0")
    parser.add_argument("--basepath", default=".")
    parser.add_argument("--show", action="store_true")
    parser.add_argument("--save", action="store_true")
    parser.add_argument("--outdir", default="figures/plots/subplots")
    parser.add_argument("--kde", action="store_true")
    parser.add_argument("--fill2D", action="store_true")
    parser.add_argument("--flip1D", action="store_true", help="Flip and rotate the secondary 1D plot")
    parser.add_argument("--flip2D", action="store_true", help="Flip 2D plot to switch var1 and var2")
    parser.add_argument("--cbar", action="store_true", help="Add colorbar to 2D plot")
    parser.add_argument("--shades", action="store_true", help="Use shaded color gradients based on FES")
    parser.add_argument("--monochrome", action="store_true", help="Use only the amor color palette")
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    # Global limits
    xlim = list(map(float, args.xlim.split(",")))
    yl2D = list(map(float, args.yl2D.split(",")))
    zlim = list(map(float, args.zlim.split(",")))

    var1, var2 = args.var.split(",")
    rat=False
    trp_wobbling = ["w1", "w2", "p0"]

    if args.flip2D:
        var1, var2 = var2, var1
        xlim, yl2D = yl2D, xlim  # Also swap axis limits

    is_angle1 = var1 in trp_wobbling
    is_angle2 = var2 in trp_wobbling

    zmin, zmax = map(float, args.zlim.split(","))
    ligands = ["amor", "crys"] if args.lig == "compare" else [args.lig]

    colors = {"amor": custom_teal_cmap()(0.5), "crys": reversed_rdpu()(0.5)}
    sigmax=1.0
    sigmay=1.0
    sigmaz=1.0

    fig, axes = plt.subplots(2, 2, figsize=(8, 6), constrained_layout=True)
    ax1D_x, ax1D_y = axes[0, 0], axes[1, 1]
    ax2D = axes[1, 0]

    for lig in ligands:
        base = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/fes"
        basw = f"{args.basepath}/{lig}/{args.exp}/r{args.rep}/wobbling"
        #cmap = custom_teal_cmap() if lig == "amor" else custom_magenta_cmap()
        if args.monochrome:
            base_colors = custom_teal_cmap()
        else:
            base_colors = custom_teal_cmap() if lig == "amor" else custom_magenta_cmap()
#        base_colors = custom_teal_cmap() if lig == "amor" else custom_magenta_cmap()
        cmap, levels, norm = discrete_cmap(base_colors, zmin, zmax, step=5)

        colors = {"amor": cmap(0.5), "crys": cmap(0.5)}  # midpoint color
        color = colors[lig]

        # Load and plot 1D
        if is_angle1:
            path1 = f"{basw}/f{var1}.dat"
        else:
            path1 = f"{base}/f{var1}.dat"
        if is_angle2:
            path2 = f"{basw}/f{var2}.dat"
        else:
            path2 = f"{base}/f{var2}.dat"
        #path1 = f"{base}/f{var1}.dat"
        #path2 = f"{base}/f{var2}.dat"
        if os.path.isfile(path1):
            x, y = load_fes_1d(path1, is_angle=var1 in trp_wobbling)
            y = gaussian_filter1d(y, sigma=sigmax) if args.kde else y
            if args.shades:
                points = np.array([x, y]).T.reshape(-1, 1, 2)
                segments = np.concatenate([points[:-1], points[1:]], axis=1)
                norm = plt.Normalize(*zlim)
                values = (y[:-1] + y[1:]) / 2  # Average y per segment
                lc = LineCollection(segments, cmap=cmap, norm=norm)
                lc.set_array(values)
                lc.set_linewidth(2)
                ax1D_x.add_collection(lc)
            else:
                ax1D_x.plot(x, y, label=lig, color=color)
        if os.path.isfile(path2):
            x, y = load_fes_1d(path2, is_angle=var2 in trp_wobbling)
            y = gaussian_filter1d(y, sigma=sigmay) if args.kde else y
            if args.shades:
                points = np.array([x, y]).T.reshape(-1, 1, 2)
                segments = np.concatenate([points[:-1], points[1:]], axis=1)
                norm = plt.Normalize(*zlim)
                values = (y[:-1] + y[1:]) / 2  # Average y per segment
                lc = LineCollection(segments, cmap=cmap, norm=norm)
                lc.set_array(values)
                lc.set_linewidth(2)
                if args.flip1D:
                    # Rotate and flip the segments
                    segments_flipped = []
                    for seg, val in zip(segments, values):
                        seg = seg[:, ::-1]  # swap x and y (rotate)
                        segments_flipped.append(seg)
                    lc = LineCollection(segments_flipped, cmap=cmap, norm=norm)
                    lc.set_array(values)
                    lc.set_linewidth(2)
                    #ax1D_y.add_collection(lc)
                 #else:
                    #ax1D_y.add_collection(lc)
                ax1D_y.add_collection(lc)
            else:
                if args.flip1D:
                    #ax1D_y.plot(y[::-1], x, label=lig, color=color)
                    ax1D_y.plot(y, x, label=lig, color=color)
                else:
                    ax1D_y.plot(x, y, label=lig, color=color)

        # Load and plot 2D
        if is_angle1 or is_angle2:
            path2D = f"{basw}/f{var1}_{var2}.dat" if not args.flip2D else f"{basw}/f{var2}_{var1}.dat"
        else:
            path2D = f"{base}/f{var1}_{var2}.dat" if not args.flip2D else f"{base}/f{var2}_{var1}.dat"
        #path2D = f"{base}/f{var1}_{var2}.dat" if not args.flip2D else f"{base}/f{var2}_{var1}.dat"
        if os.path.isfile(path2D):
            x, y, z = load_fes_2d(path2D, flip=args.flip2D, angle_vars=[is_angle1, is_angle2])
            print(f"{var1}-{var2} -> x: {x.shape}, y: {y.shape}, z: {z.shape}")
            z[z > zmax] = np.nan
            z[z < zmin] = np.nan
            print(np.nanmin(z), np.nanmax(z), np.isnan(z).sum())
            z = gaussian_filter(z, sigma=sigmaz) if args.kde and args.fill2D else z
            X, Y = np.meshgrid(x, y) # Works fine with z.shape == (len(y), len(x))

            #cmap = custom_teal_cmap() if lig == "amor" else custom_magenta_cmap() #reversed_rdpu()
            cmap = base_colors
            contourf = None
            #n_levels = 25
            #levels = np.linspace(0, 1, n_levels) ** 2  # Squared: more lines near start
            #levels = levels * (zmax - zmin) + zmin
            levels = np.arange(zmin, zmax + 5, 2)
            if args.fill2D:
                #levels = np.arange(zmin, zmax + 5, 5) # levels = 80
                contourf = ax2D.contourf(X, Y, z, levels=levels, cmap=cmap, norm=norm, alpha=0.7)
                #contourf = ax2D.contourf(X, Y, z, levels=levels, cmap=cmap, alpha=0.2)
            if args.shades:
                #levels = np.arange(zmin, zmax + 5, 2)
                norm = plt.Normalize(zmin, zmax)
                shaded_colors = [cmap(norm(v)) for v in levels]
                contourf = ax2D.contourf(X, Y, z, levels=levels, cmap=cmap, norm=norm, alpha=0.7)
                ax2D.contour(X, Y, z, levels=levels, colors=shaded_colors, linewidths=1.0, alpha=0.7)
                #ax2D.contour(X, Y, z, levels=np.arange(zmin, zmax + 5, 5), cmap=cmap, linewidths=1.0)
            else:
                if args.fill2D:
                    color='white'
                ax2D.contour(X, Y, z, levels=np.arange(zmin, zmax + 5, 5), colors=[color], linewidths=0.8)
            #ax2D.contour(X, Y, z, levels=np.arange(zmin, zmax + 5, 5), colors=[color], linewidths=0.8)
            s=1.0
            p=0.5 # -0.25
            if args.cbar and contourf is not None:
            #    cbar = fig.colorbar(contourf, ax=ax2D, shrink=s, pad=p)
                cbar = fig.colorbar(contourf, ax=ax2D, shrink=s, pad=p, ticks=np.arange(zmin, zmax + 1, 10))
                cbar.set_label("FES (kJ/mol)")

            #if args.cbar and args.shades:
            if args.cbar and args.shades and contourf is not None:
            #    sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(*zlim))
            #    sm.set_array([])  # Required by colorbar
            #    cbar = fig.colorbar(contourf, ax=ax2D, spacing='proportional') # ticks=levels
            #    cbar = fig.colorbar(sm, ax=ax2D, shrink=s, pad=p)
                cbar = fig.colorbar(contourf, ax=ax2D, shrink=s, pad=p, ticks=np.arange(zmin, zmax + 1, 10))
                cbar.set_label("FES (kJ/mol)")
                pass

    if var1 in trp_wobbling:
        un1 = 'deg'
    else:
        un1 = 'nm'
    if var2 in trp_wobbling:
        un2 = 'deg'
    else:
        un2 = 'nm'
    ax1D_x.set_xlabel(f"{var1} ({un1})")
    ax1D_x.set_ylabel("FES (kJ/mol)")
    ax2D.set_xlabel(f"{var1} ({un1})")
    ax2D.set_ylabel(f"{var2} ({un2})")
    
    # Apply to 1D var1
    if var1 in trp_wobbling:
        xlim1 = -180,180
    else:
        xlim1 = xlim
    ax1D_x.set_xlim(xlim1)
    ax1D_x.set_ylim(zlim)
    # Apply to 1D var2
    if args.flip1D:
        ax1D_y.set_xlim(zlim)  # Invert y-axis flipped as x-axis
        if var2 in trp_wobbling:
            ylim2 = -180,180
        else:
            ylim2 = yl2D
        ax1D_y.set_ylim(ylim2) # ylim
        ax1D_y.set_xlabel("FES (kJ/mol)")
        ax1D_y.set_ylabel(f"{var2} ({un2})")
    else:
        if var2 in trp_wobbling:
            xlim2 = -180,180
        else:
            xlim2 = yl2D
        ax1D_y.set_xlim(xlim2) # yl2D # 1D y-plot is along second var → uses yl2D
        ax1D_y.set_ylim(zlim)
        ax1D_y.set_xlabel(f"{var2} ({un2})")
        ax1D_y.set_ylabel("FES (kJ/mol)")
    
    # Apply to 2D
    if args.flip2D:
        # flipped: var1 = y-axis originally, now X; var2 = x-axis originally, now Y
        if var1 in trp_wobbling:
            ax2D.set_xlim(-180, 180)
        else:
            ax2D.set_xlim(yl2D)
    
        if var2 in trp_wobbling:
            ax2D.set_ylim(-180, 180)
        else:
            ax2D.set_ylim(xlim)
    else:
        if var1 in trp_wobbling:
            ax2D.set_xlim(-180, 180)
        else:
            ax2D.set_xlim(xlim)
    
        if var2 in trp_wobbling:
            ax2D.set_ylim(-180, 180)
        else:
            ax2D.set_ylim(yl2D)

#    if args.flip2D:
#        if var1 in trp_wobbling:
#            xlim1 = -180,180
#        else:
#            xlim1 = xlim
#        if var2 in trp_wobbling:
#            xlim2 = -180,180
#            ax2D.set_ylim(xlim2[::-1]) # yl2D  # Flip Y-axis direction to keep it upright
#        else:
#            xlim2 = yl2D
#            ax2D.set_ylim(xlim2)#[::-1]) # yl2D  # Flip Y-axis direction to keep it upright
#        ax2D.set_xlim(xlim1) # xlim
#        #ax2D.set_ylim(xlim2)#[::-1]) # yl2D  # Flip Y-axis direction to keep it upright
#    else:
#        if var1 in trp_wobbling:
#            xlim1 = -180,180
#        else:
#            xlim1 = xlim
#        if var2 in trp_wobbling:
#            xlim2 = -180,180
#        else:
#            xlim2 = yl2D
#        ax2D.set_xlim(xlim1) # xlim
#        ax2D.set_ylim(xlim2) # yl2D

    if args.cbar and not args.shades: # add just if we want extra details. not properly named
        ax1D_x.legend()
        ax1D_y.legend()
    axes[0, 1].axis('off')

    labels = ''
    kde    = ''
    shades = ''
    fill2D = ''
    flip1D = ''
    m      = ''

    if args.cbar:
       labels = '_labels'
    if args.kde:
       kde = '_kde'
    if args.shades:
       shades = '_shades'
    if args.fill2D:
       fill2D = '_fill'
    if args.flip1D:
       flip1D = '_flip' # 2D no need as var order is flipped too
    if args.monochrome:
        m = '_m'

    outname = f"{args.outdir}/{args.lig}_{var1}_{var2}_grid{fill2D}{shades}{kde}{labels}{flip1D}{m}.png"
    if args.save:
        plt.savefig(outname, dpi=300)
        print(f"[Saved] {outname}")
    if args.show:
        plt.show()

if __name__ == "__main__":
    main()

