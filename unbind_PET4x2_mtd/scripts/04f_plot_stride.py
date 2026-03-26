#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import numpy as np
import matplotlib.pyplot as plt
import glob
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(description="Plot FES strides with adjustable parameters.")
parser.add_argument("--fig_dir", type=str,   default="bb",  help="Figure directory name")
parser.add_argument("--start",   type=int,   default=200,   help="time (ns) to start ploting fes sride")
parser.add_argument("--end",     type=int,   default=600,   help="time (ns) to start ploting fes sride")
parser.add_argument("--stride",  type=int,   default=2000,  help="fes stride")
parser.add_argument("--suff",    type=str,   default=None,  help="suffix for output file")
parser.add_argument("--xmax",    type=float, default=10.0,  help="xaxis (nm) max")
parser.add_argument("--ymax",    type=float, default=100.0, help="yaxis (nm) max")
parser.add_argument("--ligs",    nargs='+',  default=["amor","crys"], help="lig to show")
parser.add_argument("--save",    action="store_true",                 help="save or show")

# Parse arguments
args = parser.parse_args()

# Assign variables
fig_dir = args.fig_dir
start   = args.start
end     = args.end
stride  = args.stride
xmax    = args.xmax
ymax    = args.ymax
ligs    = args.ligs
save    = args.save

# 1 HILL = 0.002 ps (timestep) * 500 steps = 1 ps / HILL
# stride 2000 = 2 ns / fep
# start 400 / 2 ns / fep = 200 (n_fep) = sd0_200.dat
fep_fr = 1*0.002*500*0.001*stride # fep frequency 2 ns / fep
first_a  = start / fep_fr
first_c  = start / fep_fr
last_a   = end   / fep_fr
last_c   = end   / fep_fr

amor_dir = f'amor/s{stride}/'
crys_dir = f'crys/s{stride}/'
if args.suff is not None:
    suff = args.suff
else:
    suff     = f'_s{stride}_time_{start}_{end}'

# Load data
def load_fes_data(directory):
    num_files = len(glob.glob(directory + "sd0_*.dat"))
    #files = sorted(glob.glob(directory + "sd*.dat"))  # Sorted for correct order # sd0_1.dat sd0_10.dat sd0_11.dat ... sd0_2.dat sd0_20.dat ...
    data_list = []
    #for file in files:
    for i in range(num_files):
        file = glob.glob(directory + f'sd0_{i}.dat')[0] # Takes the first out of the list (glob returns a list even from 1 element) # np.loadtxt needs a string not a list
        if file: # Ensure the file exists
            try:
                data = np.loadtxt(file, comments="#")  # Skip header lines
                data_list.append(data)
            except Exception as e:
                print(f"Error reading {file}: {e}")
    return data_list

amor_data = load_fes_data(amor_dir)
crys_data = load_fes_data(crys_dir)

# Extract x values (first column) and FES values (second column)
x_amor   = [data[:, 0] for data in amor_data]
amor_fes = [data[:, 1] for data in amor_data]
x_crys   = [data[:, 0] for data in crys_data]
crys_fes = [data[:, 1] for data in crys_data]

# Define colors (light to dark)
num_lines_a = len(amor_fes)
num_lines_c = len(crys_fes)
amor_colors = [plt.cm.Blues(i / num_lines_a) for i in range(num_lines_a)]
crys_colors = [plt.cm.Oranges(i / num_lines_c) for i in range(num_lines_c)]

print(start,end,first_a,last_a,round(first_a),round(last_a),range(round(first_a), round(last_a)),num_lines_a)
print(start,end,first_c,last_c,round(first_c),round(last_c),range(round(first_c), round(last_c)),num_lines_c)

if last_a > num_lines_a:
    last_a = num_lines_a
if last_c > num_lines_c:
    last_c = num_lines_c

print(num_lines_a,last_a)
print(num_lines_c,last_c)

# Plot
plt.figure(figsize=(8, 4))

for i in range(round(first_a), round(last_a)):
    if "amor" in ligs:
        plt.plot(x_amor[i], amor_fes[i], color=amor_colors[i], alpha=1.00)

for i in range(round(first_c), round(last_c)):
    if "crys" in ligs:
        plt.plot(x_crys[i], crys_fes[i], color=crys_colors[i], alpha=1.00)

# Labels and limits
plt.xlabel("dc (nm) - COM distance") # d0
plt.ylabel("Free Energy (kJ/mol)")
plt.xlim(0,xmax)
plt.ylim(0,ymax)
#plt.title(f"FEPs amor (b) vs crys (o) - {start}:{end} [ns]")

# Show plot
if save:
    plt.savefig(f'figures/{fig_dir}/com_2PET_stride{suff}.png')
    print(f'Image saved at: figures/{fig_dir}/com_2PET_stride{suff}.png')
else:
    plt.show()
