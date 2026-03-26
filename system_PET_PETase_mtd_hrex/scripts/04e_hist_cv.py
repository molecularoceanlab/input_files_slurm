#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import matplotlib.pyplot as plt
import numpy as np
import os
import argparse

def read_header(file_path):
    try:
        with open(file_path, 'r') as file:
            for line in file:
                if line.startswith("#! FIELDS"):
                    fields = line.split()[2:]
                    return {field: idx for idx, field in enumerate(fields)}
        raise ValueError("No header line found")
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def load_data(file_path):
    try:
        return np.genfromtxt(file_path, comments='#', invalid_raise=False)
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return None

# Argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--exp", help="Experiment name, e.g. cv_1 or hrex_mtd")
parser.add_argument("--syst", default="6eqe_2", help="System name (default: 6eqe_2)")
parser.add_argument("--colvar", default="colvar", help="Colvar file nale (default: colvar)")
parser.add_argument("--rep", type=int, help="Optional replicate index")
args = parser.parse_args()

exp = args.exp
syst = args.syst
colvar = args.colvar
rep = args.rep

# Fixed parameters
ligs = ['amor', 'crys']
cvs = ['h0' , 'h1', 's0', 'd0', 'x0', 'x1']
colors = {'MD': 'slategrey', 'amor': 'tab:blue', 'crys': 'tab:orange'}

for lig in ligs:
    for cv in cvs:
        file = colvar
        file_ref = 'colvar'

        # Unbiased
        path_ref = f"{lig}/cv_0/{file_ref}"
        var_ref = read_header(path_ref)
        if not var_ref or cv not in var_ref:
            print(f"Skipping reference: {path_ref}, variable {cv} not found.")
            continue
        data_ref = load_data(path_ref)
        if data_ref is None:
            continue
        col_ref = var_ref[cv]
        values_ref = data_ref[:, col_ref]

        # Biased
        if exp.startswith("cv_"):
            path_exp = f"{lig}/{exp}/{file}"
        else:
            r_dir = f"r{rep if rep is not None else 0}"
            path_exp = f"{lig}/{exp}/{r_dir}/{file}"

        print(path_exp)

        var_exp = read_header(path_exp)
        if not var_exp or cv not in var_exp:
            print(f"Skipping experiment: {path_exp}, variable {cv} not found.")
            continue
        data_exp = load_data(path_exp)
        if data_exp is None:
            continue
        col_exp = var_exp[cv]
        values_exp = data_exp[:, col_exp]

        # Output
        outdir = f"figures/{syst}/{exp}"
        if rep is not None:
            outdir += f"/{rep}"
        outdir += "/hist"
        os.makedirs(outdir, exist_ok=True)
        outfile = f"{outdir}/{file}_{lig}_{rep if rep is not None else 0}_{cv}_hist.png"

        # Plot
        plt.figure(figsize=(16, 9), dpi=300)
        plt.hist(values_ref, bins=250, alpha=0.6, label=f'MD {lig} {cv}', color=colors['MD'], density=True)
        plt.hist(values_exp, bins=250, alpha=0.6, label=f'{exp} {lig} {cv}', color=colors[lig], density=True)

        plt.xlabel(f"Value of {cv}", size=50)
        plt.ylabel("Frequency", size=50)
        plt.title(f"{lig} {cv} - {exp}", size=70)
        plt.xlim(0, 1.2)
        plt.ylim(0, 50)
        plt.tick_params(axis='both', labelsize=50, length=10, width=2)
        #plt.legend()
        plt.savefig(outfile, bbox_inches='tight')
        plt.close()
        print(f"Saved histogram to {outfile}")

