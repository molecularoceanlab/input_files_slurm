#!/usr/bin/env python3
# -*- coding: UTF8 -*-

#run pymol/load.py

lig  = f'amor'
pdb  = f'{lig}/mtd.fit.pdb'
xtc  = f'{lig}/mtd.fit.xtc'
name = f'{lig}'
skip = 1

print("lig  = f'amor'\npdb  = f'{lig}/mtd.fit.pdb'\nxtc  = f'{lig}/mtd.fit.xtc'\nname = f'{lig}'\nskip = 1")
print("load_fit(pdb=pdb, xtc=xtc, name=name, skip=skip)")
print("solvent_view(name=name)")
print("lig_view(name=name)")
print("load_light(pdb=pdb, xtc=xtc, name=name, skip=skip)")

def load_light(pdb=pdb, xtc=xtc, name=name, skip=skip):
    pdb = f'{pdb}'
    xtc = f'{xtc}'
    cmd.load(f'{pdb}',f'{name}')
    cmd.load_traj(f'{xtc}',f'{name}',interval=skip)
    cmd.hide('everything',f'hydrogens and {name}')
    cmd.color('deepteal',f'resname UNK and elem C* and {name}')
    cmd.remove('solvent or inorganic')

def load_fit(pdb=pdb, xtc=xtc, name=name, skip=skip):
    pdb = f'{pdb}'
    xtc = f'{xtc}'
    cmd.load(f'{pdb}',f'{name}')
    cmd.load_traj(f'{xtc}',f'{name}',interval=skip)
    cmd.hide('everything',f'hydrogens and {name}')
    cmd.color('deepteal',f'resname UNK and elem C* and {name}')

def loop_min(lig=lig):
    if   lig == "amor":
        m = [0.05,0.20,0.55,1.30,1.55,2.10,2.50]
    elif lig == "crys":
        m = [0.40,0.65,1.00,1.35,1.70,2.10,2.40]
    for i in range(len(m)):
        pdb=f'{lig}/mtd.dry.pdb'
        xtc=f'{lig}/fes_min/PETs_{m[i]:.2f}.xtc'
        name=f'{lig}_{m[i]:.2f}'
        skip=1
        load_fit(pdb=pdb, xtc=xtc, name=name, skip=skip)

def solvent_view(name=name):
    cmd.hide('everything',f'hydrogens and {name}')
    cmd.show('spheres',f'solvent and elem O and {name}')
    cmd.set('sphere_scale',0.05,f'{name}')
    cmd.set('sphere_transparency',0.5,f'{name}')
    cmd.color('grey50',f'solvent and {name}')

def lig_view(name=name):
    cmd.orient(f'resname UNK and chain A')
    cmd.color('lightpink',f'resname UNK and chain B and elem C* and {name}')
