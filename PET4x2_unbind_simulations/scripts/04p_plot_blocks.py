#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import numpy as np
import matplotlib.pyplot as plt
import os

# Setup CLI
parser = argparse.ArgumentParser(description="Plot error vs block size for a given CV")
parser.add_argument("--cv", default="d0", help="Collective variable (e.g. d0, h0)")
parser.add_argument("--show", action="store_true", help="Show plot interactively")
parser.add_argument("--save", action="store_true", help="Save plot to file")

args = parser.parse_args()

ligs = ["amor", "crys"]
colors = {"amor": "tab:blue", "crys": "tab:orange"}
data = {}

for lig in ligs:
    path = f"{lig}/blocks.{args.cv}/err.blocks"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        continue
    arr = np.loadtxt(path)
    data[lig] = arr

# Plot
plt.figure(figsize=(10, 6), dpi=300)
for lig in data:
    x = data[lig][:, 0]
    y = data[lig][:, 1]
    plt.plot(x, y, label=lig, linewidth=2, color=colors[lig])

plt.xlabel("Block size", fontsize=16)
plt.ylabel("Average Free Energy (kJ/mol)", fontsize=16)
plt.title(f"Block Error Analysis: {args.cv}", fontsize=20)
plt.legend(fontsize=14)
plt.tight_layout()
plt.xlim(0,2000)

# Save or show
outfile = f"figures/bb/{args.cv}_block_error.png"
os.makedirs(os.path.dirname(outfile), exist_ok=True)

if args.save:
    plt.savefig(outfile)
    print(f"Saved plot to {outfile}")

if args.show:
    plt.show()

plt.close()

