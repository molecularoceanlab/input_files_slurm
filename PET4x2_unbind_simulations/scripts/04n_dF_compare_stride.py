#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import argparse
import numpy as np
import os
import glob

def extract_fes_value(filename, threshold):
    """Extract FES value at given CV (threshold) from a single file."""
    data = np.loadtxt(filename, comments="#")
    idx = (np.abs(data[:, 0] - threshold)).argmin()
    cv, fes = data[idx, 0], data[idx, 1]
    return fes

def main():
    parser = argparse.ArgumentParser(description="Compare FES between amor and crys at a specific CV value.")
    parser.add_argument("--cv", type=float, default=3.00, help="CV value to extract (default: 3.00 nm)")
    parser.add_argument("--start", type=float, default=0.0, help="Start time in ns (default: 0 ns)")
    parser.add_argument("--end", type=float, default=500.0, help="End time in ns (default: 500 ns)")
    parser.add_argument("--stride_ns", type=float, default=5.0, help="Stride between FES files in ns (default: 50 ns)")
    parser.add_argument("--amor_dir", default="amor/s5000", help="Directory for amor FES files")
    parser.add_argument("--crys_dir", default="crys/s5000", help="Directory for crys FES files")
    args = parser.parse_args()

    # Map time window to file indices
    stride = args.stride_ns
    start_idx = int(args.start // stride)
    end_idx = int(args.end // stride)

    # Get matching files
    diffs = []
    for i in range(start_idx, end_idx + 1):
        amor_file = os.path.join(args.amor_dir, f"sd0_{i}.dat")
        crys_file = os.path.join(args.crys_dir, f"sd0_{i}.dat")
        if os.path.exists(amor_file) and os.path.exists(crys_file):
            fes_amor = extract_fes_value(amor_file, args.cv)
            fes_crys = extract_fes_value(crys_file, args.cv)
            diff = fes_crys - fes_amor
            #print(f"sd0_{i}.dat", fes_crys, fes_amor, diff)
            diffs.append(diff)
        else:
            continue
            print(f"Skipping timepoint {i}: Missing files.")

    if diffs:
        avg_diff = np.mean(diffs)
        print(f"\nAverage ΔF (crys - amor) at CV={args.cv:.2f} nm over {args.start}-{args.end} ns: {avg_diff:.3f} kJ/mol")
    else:
        print("No data available in the selected window.")

if __name__ == "__main__":
    main()

