#!/usr/bin/env python3
# -*- coding: UTF8 -*-

prot = '6eqe'
lig = 'amor'
ligs = ['amor','crys']

print(prot)

template_path='templates/prot_prep'

import sys
sys.path.append(template_path)
import pymol
from pymol import cmd
import basics_pymol as bs

for lig in ligs:
    cmd.load(f'{lig}/eq2.dry.pdb', f'{lig}')
    cmd.load_traj(f'{lig}/eq2.dry.short_10.xtc',f'{lig}',interval=100)
    AS = bs.select_AS(f'{prot}')
    OX = bs.select_OX(f'{prot}')
    TRP = bs.select_TRP(f'{prot}')
    cmd.show('sticks',f'resi {AS}+{OX}+{TRP} and not hydrogens')
    cmd.hide('everything',f'hydrogens')
    cmd.show('sticks',f'resi {AS} and sidechain')
    cmd.center(f'resname UNK')
    cmd.zoom(f'resi {AS}+{OX}+{TRP}')
    cmd.color('white',f'polymer')
    cmd.color('deepteal',f'resname UNK and elem C*')
    cmd.color('magenta',f'resi {AS} and elem C*')
    cmd.color('purple',f'resi {OX} and elem C*')
    cmd.color('atomic',f'resi {AS}+{OX}+{TRP} and not elem C*')
