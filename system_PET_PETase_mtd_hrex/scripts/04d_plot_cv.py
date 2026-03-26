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

def moving_average(data, window=1000):
    return np.convolve(data, np.ones(window) / window, mode='valid')

# Argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--exp", default="hrex_mtd", help="Experiment name, e.g. cv_1 or hrex_mtd")
parser.add_argument("--ligs",                     nargs='+', default=["amor","crys"],        help="lig to show")
parser.add_argument("--cvs",                      nargs='+', default=["h0","d0","h1","s0"],        help="lig to show")
parser.add_argument("--syst", default="6eqe_2", help="System name (default: 6eqe_2)")
parser.add_argument("--folder", default="fes", help="Directory name (default: fes)")
parser.add_argument("--colvar", default="colvar", help="Colvar file nale (default: colvar)")
parser.add_argument("--rep", default=0, type=int, help="Optional replicate index")
parser.add_argument("--maxtime", type=int, default=1000, help="max time simulation")
parser.add_argument("--ref", action="store_true")
parser.add_argument("--save", action="store_true")
parser.add_argument("--show", action="store_true")
args = parser.parse_args()

exp = args.exp
syst = args.syst
folder  = args.folder
colvar = args.colvar
rep = args.rep
maxtime = args.maxtime

# Fixed parameters
ligs = args.ligs #['amor', 'crys']
cvs = args.cvs #['h0', 'h1', 's0', 'd0', 'x0', 'x1']
#colors = {'MD': 'slategrey', 'amor': 'tab:blue', 'crys': 'tab:orange'}
colors = {
    'MD': 'slategrey',
    'amor': '#3DC1B8',   # cyan for aPET
    'crys': '#E61E72'    # magenta for cPET
}

for lig in ligs:
    for cv in cvs:
        file = colvar
        file_ref = 'colvar'

        # Build path for unbiased reference (cv_0)
        if args.ref:
            path_ref = f"{lig}/cv_0/{file_ref}"
            var_ref = read_header(path_ref)
            if not var_ref or cv not in var_ref:
                print(f"Skipping reference: {path_ref}, variable {cv} not found.")
                continue
            data_ref = load_data(path_ref)
            if data_ref is None:
                continue
            col_ref = var_ref[cv]
            time_ref = data_ref[:, 0] * 0.001
            values_ref = data_ref[:, col_ref]
            ma_ref = moving_average(values_ref, 100)

        # Build path for current experiment
        if exp.startswith("cv_"):
            path_exp = f"{lig}/{exp}/{file}"
        else:
            r_dir = f"r{rep if rep is not None else 0}"
            #path_exp = f"{lig}/{exp}/{r_dir}/{file}"
            path_exp = f"{lig}/{exp}/{r_dir}/{folder}/{file}"

        var_exp = read_header(path_exp)
        if not var_exp or cv not in var_exp:
            print(f"Skipping experiment: {path_exp}, variable {cv} not found.")
            continue
        data_exp = load_data(path_exp)
        if data_exp is None:
            continue
        col_exp = var_exp[cv]
        time_exp = data_exp[:, 0] * 0.001
        values_exp = data_exp[:, col_exp]
        ma_exp = moving_average(values_exp, 100)
        if args.ref:
            print(path_ref,data_ref.shape)
        print(path_exp,data_exp.shape)

        # Prepare output directory
        outdir = f"figures/{syst}/{exp}"
        if rep is not None:
            outdir += f"/r{rep}"
        os.makedirs(outdir, exist_ok=True)
        outfile = f"{outdir}/line/{file}_{lig}_{rep if rep is not None else 0}_{cv}_line.png"

        # Plotting
        plt.figure(figsize=(16, 9), dpi=300)
        if args.ref:
            plt.plot(time_ref, values_ref, label=f'MD {lig} {cv} raw', alpha=0.3, color=colors['MD'])
            #plt.plot(time_ref[:len(ma_ref)], ma_ref, label=f'MD {lig} {cv} ma', linewidth=2, color=colors['MD'])

        plt.plot(time_exp, values_exp, label=f'{exp} {lig} {cv} raw', alpha=1, color=colors[lig])
        #plt.plot(time_exp, values_exp, label=f'{exp} {lig} {cv} raw', alpha=0.3, color=colors[lig])
        #plt.plot(time_exp[:len(ma_exp)], ma_exp, label=f'{exp} {lig} {cv} ma', linewidth=2, color=colors[lig])

        #plt.xlabel("Time (ns)",size=50)
        #plt.ylabel("Distance (nm)",size=50)
        plt.title(f"{lig} {cv} - {exp}",size=70)
        plt.xlim(0,maxtime)
        plt.ylim(0, 1.2)
        #plt.legend()
        plt.tick_params(axis='both', labelsize=50, length=10, width=2)
        if args.save:
            plt.savefig(outfile, bbox_inches='tight')
            print(f"Saved plot to {outfile}")
        if args.show:
            plt.show()
        plt.close()

