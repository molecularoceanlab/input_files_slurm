#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import ast  # To safely evaluate tuple strings
import numpy as np
import matplotlib.pyplot as plt
import sys

dir = sys.argv[1] if len(sys.argv) > 1 else "bb"
print(f"Using directory: {dir}")

def load_colvar(file_path):
    data = np.loadtxt(file_path, comments="#")
    time = data[:, 0]
    d0 = data[:, 1]
    d1 = data[:, 2]
    d2 = data[:, 3]
    d3 = data[:, 4]
    d4 = data[:, 5]
    metad_bias = data[:, 6]
    return time, d0, d1, d2, d3, d4, metad_bias

amor_cv = "amor/colvar"
crys_cv = "crys/colvar"

time_amor, d0_amor, d1_amor, d2_amor, d3_amor, d4_amor, metad_bias_amor = load_colvar(amor_cv)
time_crys, d0_crys, d1_crys, d2_crys, d3_crys, d4_crys, metad_bias_crys = load_colvar(crys_cv)

# Plotting
plt.figure(figsize=(8, 6))
plt.plot(time_amor*0.001, d0_amor, linewidth=2, alpha=0.8, label="Amorphous")
plt.plot(time_crys*0.001, d0_crys, linewidth=2, alpha=0.8, label="Crystalline")

plt.ylim(0.0,14.0)
plt.xlabel("time (ns)", fontsize=12)
plt.ylabel("d0 (nm)", fontsize=12)
plt.title("com distances 2PET (d0)", fontsize=14)
plt.legend()
plt.tight_layout()

# Save the plot or display
plt.savefig(f"figures/{dir}/com_2PET_1D.png")  # Save as a file
plt.show()  # Display the plot

