#!/usr/bin/env python3
# -*- coding: UTF8 -*-

# plot 2d surface d0 vs h0
# for syst in 6eqe 7nei 6ths 6tht; do for lig in amor crys; do ./scripts/04_analysis/04f_plot_2d_fes.py $syst $lig f0d "d0" "h0" "distances of lig from cat-ser vs ox-hole" 20; done; done

import sys
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# Function to construct the file path
def construct_filepath(system, state, fes):
    return f"systs/{system}/04_analysis/{state}/r0/{fes}.dat"

# Check if the correct number of arguments is provided
if len(sys.argv) != 8:
    print("Usage: python script_name.py <system> <state> <fes> <xlabel> <ylabel> <title> <zmax>")
    sys.exit(1)

# Parse command line arguments
system = sys.argv[1]
state = sys.argv[2]
fes = sys.argv[3]
xlabel = sys.argv[4]
ylabel = sys.argv[5]
title = sys.argv[6]
zmax = float(sys.argv[7])

# Construct the data file path
filename = construct_filepath(system, state, fes)

# Check if the file exists
if not os.path.isfile(filename):
    print(f"Error: File {filename} does not exist.")
    sys.exit(1)

# Load the data from the specified file
data = np.loadtxt(filename, comments='#')

# Extract columns
d0 = data[:, 0]
h0 = data[:, 1]
df0 = data[:, 2]

# Normalize df0 to be zero-based
df0 = df0 - np.min(df0)

# Remove non-finite values
finite_mask = np.isfinite(df0)
d0 = d0[finite_mask]
h0 = h0[finite_mask]
df0 = df0[finite_mask]

# Define Arduino colors in the desired sequence, reversed
arduino_divergent = ['#c11f09','#d35400', '#e67e22', '#f39c12', '#f1c40f', '#7fcbcd', '#0ca1a6', '#00979d', '#008184', '#006d70', '#005c5f', '#4e5b61', '#7f8c8d', '#95a5a6', '#bdc7c7', '#c9d2d2', '#dae3e3', '#ecf1f1', '#f7f9f9', '#f4f4f4','#fff']
arduino_teal = ['#7fcbcd', '#0ca1a6', '#00979d', '#008184', '#006d70', '#005c5f', '#4e5b61', '#7f8c8d', '#95a5a6', '#bdc7c7', '#c9d2d2', '#dae3e3', '#ecf1f1', '#f7f9f9', '#f4f4f4','#fff']
# Create a list of colors for LinearSegmentedColormap
ard_colors = arduino_teal

# Create a LinearSegmentedColormap using the defined colors
custom_arduino = LinearSegmentedColormap.from_list('arduino_colormap', ard_colors, N=256)

# Load the twilight_shifted_r colormap
# twilight_shifted_r terrain PuBuGn *_r reverse
cmap_to_custom = plt.get_cmap('bone')

# Extract the colors as RGBA values and convert to list
cmap_colors = cmap_to_custom(np.linspace(0, 1, 256)).tolist()

# Add light grey color at the top
cmap_colors[-1] = [0.83, 0.83, 0.83, 0.0]  # Light grey in RGBA but fully transparent (alpha value)
# Modify the first color (deep blue) to a tiny shade of teal
#cmap_colors[0] = [0.0, 0.5, 0.5, 1.0]  # RGBA for a very tiny shade of teal

# Create a new LinearSegmentedColormap with the modified colors
custom_cmap = LinearSegmentedColormap.from_list('custom_cmap', cmap_colors)

# Create the plot with the custom colormap
plt.figure(figsize=(10, 8))  # Adjust figure size as needed
#sc = plt.scatter(d0, h0, c=df0, cmap=custom_arduino, marker='s')
sc = plt.scatter(d0, h0, c=df0, cmap=custom_cmap, marker='s')
cbar = plt.colorbar(sc, label='free-energy (normalized) [kJ/mol]')
cbar.ax.tick_params(labelsize=20)  # Adjust the font size of the colorbar ticks
cbar.set_label('free-energy (normalized) [kJ/mol]', fontsize=20)  # Adjust the font size of the colorbar label
plt.xlabel(f'{xlabel} [nm]', fontsize=20)
plt.ylabel(f'{ylabel} [nm]', fontsize=20)
plt.tick_params(axis='both', which='major', labelsize=20)
plt.title(f'{system}_{state}_{fes} {title} FES')
plt.xlim(0.2, 0.8)
plt.ylim(0.2, 0.8)
sc.set_clim(0, zmax)  # Set the color limit from 0 to zmax kJ/mol
plt.grid(True)

# Create a grid for contour plot
xi = np.linspace(d0.min(), d0.max(), 500)
yi = np.linspace(h0.min(), h0.max(), 500)
zi = plt.tricontour(d0, h0, df0, levels=np.arange(0, zmax+2, 2), linewidths=0.5, colors='k')

# Save the plot as an image with higher resolution (300 DPI)
output_filename = f"figures/04_analysis/f2d_{fes}_{system}_{state}.png"
plt.savefig(output_filename, dpi=300)

# Display a message with the saved filename
print(f"Plot saved as: {output_filename}")

# Display the plot
#plt.show()
