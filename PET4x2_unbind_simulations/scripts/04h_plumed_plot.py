#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import matplotlib.pyplot as plt
import numpy as np
import sys
sys.path.append("templates/plumed/")
import read_plumed as ref

lig = 'amor'
ori_cv = f'{lig}/colvar'
pbc_cv = f'{lig}/pbc/colvar'
min_cv = f'{lig}/pbc/mindist.xvg'
files = [ori_cv,pbc_cv]
cv   = 'd0'
line_output_file = f'figures/nowalls/pbc/{lig}_line_cv.png'
hist_output_file = f'figures/nowalls/pbc/{lig}_hist_cv.png'

def plot_line():

    # Plotting
    plt.figure(figsize=(8, 6), dpi=300)

    time, min_dist = np.loadtxt(min_cv,comments=["#","@"],unpack=True)

    plt.plot(time,min_dist,alpha=0.5,label=f'{min_cv}')

    for file in files:
        data = ref.load_file(file)
        if file == pbc_cv:
            time = data['time']
            time *= 2
        else:
            time = data['time']
        plt.plot(time, data['d0'],alpha=0.5,label=f'{file}')

    # Set axes limits
    #plt.xlim(0, 560)  # X-axis in nanoseconds (ns)
    #plt.ylim(0.00, 8.50)  # Y-axis in nanometers (nm)

    plt.xlabel("Time (ns)")
    plt.ylabel("Distance d0 (nm)")
    plt.legend()

    # Save to file
#    plt.savefig(line_output_file, bbox_inches='tight', format='png')
    print(f"Line plot saved to {line_output_file}")

    # Show
    plt.show()

def plot_hist():

    # Plotting
    plt.figure(figsize=(8, 6), dpi=300)

    time, min_dist = np.loadtxt(min_cv,comments=["#","@"],unpack=True)

    plt.hist(min_dist,alpha=0.5,label=f'{min_cv}',bins=150,density=False)

    for file in files:
        data = ref.load_file(file)
        if file == pbc_cv:
            time = data['time']
            time *= 2
        else:
            time = data['time']
        plt.hist(data['d0'],alpha=0.5,label=f'{file}',bins=150,density=False)

    # Set axes limits
    #plt.xlim(0, 560)  # X-axis in nanoseconds (ns)
    #plt.ylim(0.00, 8.50)  # Y-axis in nanometers (nm)
    
    plt.xlabel("Distance d0 (nm)")
    plt.ylabel("Frequency")
    plt.legend()

    # Save to file
    plt.savefig(hist_output_file, bbox_inches='tight', format='png')
    print(f"Hist plot saved to {hist_output_file}")

    # Show
    plt.show()

plot_line()
plot_hist()
