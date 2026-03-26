#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import numpy as np
from scipy.signal import argrelmin
import sys
import matplotlib.pyplot as plt

plot=False

if len(sys.argv) > 1:
    fes = sys.argv[1]
else:
    fes = 'sd0.dat'

# Load your data
data = np.loadtxt(fes, comments='#')

cv = data[:, 0]    # d0 values
fes = data[:, 1]   # Free energy

# Find local minima
minima_indices = argrelmin(fes)[0]

# Filter minima by energy threshold (optional)
threshold = np.min(fes) + 80  # For example, within 5 kJ/mol of global min
filtered_indices = [i for i in minima_indices if fes[i] < threshold]

# Print results
print("Local minima (CV, FES):")
for i in filtered_indices:
    if cv[i] < 3.5:
        print(f"{cv[i]:.3f} {fes[i]:.3f}")

# Plot for confirmation
if plot:
    plt.plot(cv, fes, label="FES")
    plt.scatter(cv[filtered_indices], fes[filtered_indices], color='red', marker='x', label="Minima")
    plt.xlabel("CV (d0)")
    plt.ylabel("Free Energy")
    plt.xlim(0.0,4.0)
    plt.ylim(0.0,80.)
    plt.legend()
    plt.show()

