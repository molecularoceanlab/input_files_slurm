#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

# Set up argument parser
parser = argparse.ArgumentParser(description="Plot dF diff ranges")
parser.add_argument("--lig", type=str, default="crys", help="amor or crys")
parser.add_argument("--stride", type=str, default=1000, help="1000 when calculates")
parser.add_argument("--compare", action="store_true", help="compare amor vs crys")
parser.add_argument("--threshold", type=str, default="0.00_0.55_0.55_2.50", help="threshold bound unbound")
parser.add_argument("--dir", type=str, default="bb", help="directory in figures")
parser.add_argument("--save", action="store_true")

# Parse arguments
args = parser.parse_args()

# Assign variables
stride = args.stride
compare = args.compare
dir = args.dir

if compare:
    threshold = args.threshold
    #threshold = "0.00_0.55_0.55_2.50"
    files = glob.glob(f'????/s{stride}/dF/dF_{threshold}.dat')
    outfig = f'figures/{dir}/dF_error/compare_s{stride}_{threshold}.png'
else:
    lig = args.lig
    files = glob.glob(f'{lig}/s{stride}/dF/dF_*.dat')
    outfig = f'figures/{dir}/{lig}_s{stride}.png'

def plot_dF(files):
    # Plotting
    plt.figure(figsize=(10, 3), dpi=300)
    color_map = {}
    for file in files:
        # load data
        time, data = np.loadtxt(file, unpack=True)
        label = os.path.splitext(file)[0]
        lig = label.split('/')[0]
        color = plt.plot(time/1000,data,marker='.',label=None,linewidth=2.0,alpha=0.5)[0].get_color()
        color_map[file] = color
    for file in files:
        # load data
        time, data = np.loadtxt(file, unpack=True)
        label = os.path.splitext(file)[0]
        lig = label.split('/')[0]
        avg_value = np.mean(data[-200:])
        plt.axhline(y=avg_value, linestyle='--', linewidth=1.0, alpha=1.0, label=f'{lig}_avg_{round(avg_value,2)}',color=color_map[file])
    plt.xlabel("time [ns]")
    plt.ylabel("dF [kJ/mol]")
    #plt.title(f'dF_{threshold}_s{stride}')
    #plt.legend()
    if args.save:
        plt.savefig(outfig,bbox_inches='tight', format='png')
    plt.show()

print(outfig)
plot_dF(files)
