#!/usr/bin/env python3
# -*- coding: UTF8 -*-

template_path="/home/adipede/projects/petase/templates/prot_prep"
reference_file="references_petase.py"
basics_file="basics_pymol.py"

import sys
sys.path.append(template_path)
import pymol
from pymol import cmd

pymol.finish_launching()
cmd.run(f'{template_path}/{reference_file}')
cmd.run(f'{template_path}/{basics_file}')

prot = f'6eqe'
lig = f'amor'
cv = f'0'
frames = 10
pdb = f'{lig}/cv_{cv}/mtd.fit.pdb'
xtc = f'{lig}/cv_{cv}/mtd.fit.xtc'

def load_fit(path_pdb=pdb, path_xtc=xtc,syst=prot,form=lig,cv=cv,frames=frames):
    name = f'{syst}_{form}_{cv}'
    load_trajs(path_pdb,path_xtc,name,skip=frames)
    color_complex(name)

    # pulling points
    as_sele = select_AS(syst)
    cmd.select(f'act_site_{name}',f'resi {as_sele} and {name}')
    cmd.show('sticks',f'act_site_{name}')
    cmd.color('magenta',f'act_site_{name} and elem C*')

    ox_sele = select_OX(syst)
    cmd.select(f'ox_hole_{name}',f'resi {ox_sele} and {name}')
    cmd.show('sticks',f'ox_hole_{name}')
    cmd.color('lightpink',f'ox_hole_{name} and elem C*')

    # distances
    serOG = f'act_site_{name} and resn SER and name OG'
    metN = f'ox_hole_{name} and resn MET and name N'
    tyrN = f'ox_hole_{name} and resn TYR and name N'
    ligC19 = f'name C19 and {name}'
    ligC39 = f'name C39 and {name}'
    ligC17 = f'name C17 and {name}'
    ligO7  = f'name O7 and {name}'
#    cmd.distance(f'pull', serOG, ligC19, 10)
#    cmd.distance(f'metN', metN, ligO7, 10)
#    cmd.distance(f'tyrN', tyrN, ligO7, 10)

    cmd.deselect()
    cmd.hide('everything','hydrogens')
    cmd.hide('everything','solvent or inorganic')
    nstates = cmd.count_states()
    cmd.frame(nstates)
    cmd.orient(f'act_site or ox_hole or resname UNK')
