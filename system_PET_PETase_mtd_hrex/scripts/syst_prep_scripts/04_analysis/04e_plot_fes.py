#!/usr/bin/env python3
# -*- coding: UTF8 -*-

# plot fes for d0 or h0 min to zero after reweight
# cv=fd0; name="ser-lig"; for syst in 6eqe 7nei 6ths 6tht; do echo $syst $cv $name; ./scripts/04_analysis/04e_plot_fes.py $syst $cv $name ; done
# cv=fh0; name="met-lig"; for syst in 6eqe 7nei 6ths 6tht; do echo $syst $cv $name; ./scripts/04_analysis/04e_plot_fes.py $syst $cv $name --no-show ; done

import numpy as np
import matplotlib.pyplot as plt
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(description='Plot fd0 vs d0 for given system and ligand.')
parser.add_argument('syst', type=str, help='System name (e.g., 7nei)')
parser.add_argument('cv', type=str, help='System name (e.g., fd0)')
parser.add_argument('name', type=str, help='System name (e.g., ser-lig)')
parser.add_argument('--no-show', action='store_true', help="Don't display the plot.")
args = parser.parse_args()

# Load the data using f-strings to include the system name
c300 = np.loadtxt(f'systs/{args.syst}/04_analysis/c300/r0/{args.cv}.dat', comments='#')
a300 = np.loadtxt(f'systs/{args.syst}/04_analysis/a300/r0/{args.cv}.dat', comments='#')
#c350 = np.loadtxt(f'systs/{args.syst}/04_analysis/c350/r0/{args.cv}.dat', comments='#')
#a350 = np.loadtxt(f'systs/{args.syst}/04_analysis/a350/r0/{args.cv}.dat', comments='#')

# Extract the first and second columns
td0_c300 = c300[:, 0]
fd0_c300 = c300[:, 1]
td0_a300 = a300[:, 0]
fd0_a300 = a300[:, 1]
#td0_c350 = c350[:, 0]
#fd0_c350 = c350[:, 1]
#td0_a350 = a350[:, 0]
#fd0_a350 = a350[:, 1]

# Set the figure size to 16x10 inches
plt.figure(figsize=(6, 3.5))

# Plot the data
#plt.plot(td0_c300, fd0_c300 - fd0_c300.min(), label=f'{args.syst} crys 300K')
#plt.plot(td0_a300, fd0_a300 - fd0_a300.min(), label=f'{args.syst} amor 300K')
#plt.plot(td0_c350, fd0_c350 - fd0_c350.min(), label=f'{args.syst} crys 350K')
#plt.plot(td0_a350, fd0_a350 - fd0_a350.min(), label=f'{args.syst} amor 350K')

plt.plot(td0_c300, fd0_c300 - fd0_c300.min(), label=f'{args.syst} crys 300K', color='gold', linestyle='-')
plt.plot(td0_a300, fd0_a300 - fd0_a300.min(), label=f'{args.syst} amor 300K', color='turquoise', linestyle='-')
#plt.plot(td0_c350, fd0_c350 - fd0_c350.min(), label=f'{args.syst} crys 350K', color='darkorange', linestyle='-')
#plt.plot(td0_a350, fd0_a350 - fd0_a350.min(), label=f'{args.syst} amor 350K', color='teal', linestyle='-')

# Set y-axis minimum to zero
plt.xlim(0.2, 0.8)
plt.ylim(0, 30)

# Add labels and title
plt.xlabel(f'distance {args.cv} {args.name} [nm]')
plt.ylabel('fes [kcal/mol]')
#plt.title(f'Plot of fd0 vs d0 for {args.syst}')
plt.legend()

# Save the figure
plt.savefig(f'figures/04_analysis/fes_{args.cv}_{args.syst}.png')

# Conditionally show the plot based on the --no-show switch
if not args.no_show:
        plt.show()

