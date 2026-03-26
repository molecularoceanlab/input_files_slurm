#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import ast  # To safely evaluate tuple strings
import numpy as np
import matplotlib.pyplot as plt
import sys

dir = sys.argv[1] if len(sys.argv) > 1 else "bb"
xrg = ast.literal_eval(sys.argv[2]) if len(sys.argv) > 2 else (0.00, 10.00)
yrg = ast.literal_eval(sys.argv[3]) if len(sys.argv) > 3 else (0.00, 80.00)
suf = sys.argv[4] if len(sys.argv) > 4 else ""
print(f"Using directory: {dir}")
print(f"X range: {xrg}, Y range: {yrg}")

# Load data function
def load_data(file_path):
    data = np.loadtxt(file_path, comments="#")
    d0 = data[:, 0]
    file_free = data[:, 1]
    return d0, file_free

# Load data from files
amor_file = "amor/sd0.dat"
crys_file = "crys/sd0.dat"

d0_amor, file_free_amor = load_data(amor_file)
d0_crys, file_free_crys = load_data(crys_file)

# Plotting
plt.figure(figsize=(8, 6))
plt.plot(d0_amor, file_free_amor, label="Amorphous", linewidth=2)
plt.plot(d0_crys, file_free_crys, label="Crystalline", linewidth=2)

plt.xlim(xrg)
plt.ylim(yrg)
plt.xlabel("d0", fontsize=12)
plt.ylabel("FES d0", fontsize=12)
plt.title("com distances 2PET (d0)", fontsize=14)
plt.legend()
plt.tight_layout()

# Save the plot or display
plt.savefig(f"figures/{dir}/com_2PET{suf}.png")  # Save as a file
plt.show()  # Display the plot

