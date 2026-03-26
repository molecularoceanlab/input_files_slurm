#!/usr/bin/env python3
# -*- coding: UTF8 -*-

import numpy as np
import matplotlib.pyplot as plt

def load_plumed(file_path):
    """
    General function to load colvar, HILLS, or FES files dynamically.
    It reads the headers (if present) to determine column names.
    """
    with open(file_path, 'r') as f:
        first_line = f.readline().strip()
        if first_line.startswith("#! FIELDS"):
            headers = first_line.split()[2:]  # Skip "#! FIELDS"
        else:
            headers = None  # No header, assume numerical data
            f.seek(0)  # Reset file pointer
        
    data = np.loadtxt(file_path, comments="#")
    
    if headers:
        if len(headers) != data.shape[1]:
            raise ValueError(f"Header length ({len(headers)}) does not match data columns ({data.shape[1]})")
        return {headers[i]: data[:, i] for i in range(len(headers))}
    else:
        return data  # Return as numpy array if no headers

if __name__ == "__main__":
    #file_path = "example.colvar"  # Change this to your actual file
    file_path = "../../6eqe_0/04_analysis/amor/cv_1/fh0.dat"
    data = load_file(file_path)
    
    if isinstance(data, dict):
        print("Loaded columns:", list(data.keys()))
        print(data['dfh0_h0'])
        print(data)
    else:
        print("Loaded data shape:", data.shape)
