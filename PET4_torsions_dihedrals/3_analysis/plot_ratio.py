#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import sys, argparse
import numpy as np
import matplotlib.pyplot as plt

# --- palette (taken from your figure) ---
PINK_TRANS  = "#cc2b8e"  # trans
CYAN_GAUCHE = "#00a8b5"  # gauche

def load_table(path):
    d1, rT, rG = [], [], []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith(("gauche_range", "trans_range", "syst", "#")):
                continue
            cols = line.split()
            # columns: 0:syst 1:dist_lw 2:dist_av 3:#count 4:#trans 5:#gauche 6:ratio_t 7:ratio_g 8:bias_av 9:forc_lw 10:forc_av
            try:
                d1.append(float(cols[1]))
                rT.append(float(cols[6]))
                rG.append(float(cols[7]))
            except (IndexError, ValueError):
                pass
    # sort by d1 ascending
    order = np.argsort(d1)
    return np.array(d1)[order], np.array(rT)[order], np.array(rG)[order]

def main():
    ap = argparse.ArgumentParser(description="Plot trans/gauche ratios vs lower-wall distance (d1).")
    ap.add_argument("table", help="tab-separated file (e.g., ratio_0_100_180.txt)")
    ap.add_argument("-o","--out", default="ratio_vs_d1.png", help="output image (png/svg/pdf)")
    ap.add_argument("--title", default="Torsion populations vs d1 (lower wall)", help="figure title")
    args = ap.parse_args()

    d1, rT, rG = load_table(args.table)

    plt.figure(figsize=(6,4))
    plt.plot(d1, rT, "-o", lw=2, ms=4, label=f"Trans  (%) - 100:180°",  color=PINK_TRANS)
    plt.plot(d1, rG, "-o", lw=2, ms=4, label=f"Gauche (%) -   0:100°", color=CYAN_GAUCHE)

    plt.xlabel("d1 (nm)")
    plt.ylabel("Population (%)")
    plt.title(args.title)
    plt.legend()
    plt.tight_layout()
    plt.savefig(args.out, dpi=300)
    print(f"Saved: {args.out}")

if __name__ == "__main__":
    main()

