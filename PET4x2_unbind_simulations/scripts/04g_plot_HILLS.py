#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import numpy as np
import matplotlib.pyplot as plt
import sys

dir = sys.argv[1] if len(sys.argv) > 1 else "bb"
print(f"Using directory: {dir}")

def load_HILLS(file_path):
    data = np.loadtxt(file_path, comments="#")
    time     = data[:, 0]
    d0       = data[:, 1]
    sigma_d0 = data[:, 2]
    height   = data[:, 3]
    biasf    = data[:, 4]
    return time, d0, sigma_d0, height, biasf 

amor_cv = "amor/HILLS"
crys_cv = "crys/HILLS"

time_amor, d0_amor, sigma_d0_amor, height_amor, biasf_amor = load_HILLS(amor_cv)
time_crys, d0_crys, sigma_d0_crys, height_crys, biasf_crys = load_HILLS(crys_cv)

# Plotting
plt.figure(figsize=(8, 6))
plt.plot(time_amor, height_amor, linewidth=2, alpha=0.8, label="Amorphous")
plt.plot(time_crys, height_crys, linewidth=2, alpha=0.8, label="Crystalline")

#plt.xlim(0.0, 1.2)
#plt.ylim(0.0,50.0)
plt.ylim(0.0, 0.6)
plt.xlabel("time (ps)", fontsize=12)
plt.ylabel("height HILLS (kj/mol?)", fontsize=12)
plt.title("height HILLS wt mtd", fontsize=14)
plt.legend()
plt.tight_layout()

# Save the plot or display
plt.savefig(f"figures/{dir}/height_HILLS.png")  # Save as a file
plt.show()  # Display the plot

