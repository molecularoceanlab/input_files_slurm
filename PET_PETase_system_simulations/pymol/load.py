#!/usr/bin/env python3
# -*- coding: UTF8 -*-

template_path="/home/adipede/projects/petase/templates/prot_prep"
reference_file="references_petase.py"
basics_file="basics_pymol.py"
get_index="get_index.sh"

import sys
sys.path.append(template_path)
import pymol
from pymol import cmd

pymol.finish_launching()

view_prot = (
    -0.383008242,   -0.856048167,    0.347110301,
     0.149273232,   -0.428182453,   -0.891278446,
     0.911603928,   -0.289553255,    0.291782230,
     0.000000000,   -0.000000000, -165.414306641,
   -19.842992783,   58.125999451,   27.530597687,
   130.413894653,  200.414718628,  -20.000000000 )

# default
prot = f'6eqe'
lig = f'amor'
cv = f'0'
frames = 10
pdb = f'{lig}/cv_{cv}/mtd.fit.pdb'
xtc = f'{lig}/cv_{cv}/mtd.fit.xtc'

cmd.run(f'{template_path}/{reference_file}')
cmd.run(f'{template_path}/{basics_file}')

print(f"load_fit(path_xtc=f'{lig}/cv_{cv}/mtd.fit.short_20.xtc',frames=10)")
print("prot = f'6eqe'\nlig = f'amor'\ncv = f'0'\nframes = 10\npdb = f'{lig}/cv_{cv}/mtd.fit.pdb'\nxtc = f'{lig}/cv_{cv}/mtd.fit.xtc'")
print(f"load_fit(path_pdb=pdb, path_xtc=xtc,syst=prot,form=lig,cv=cv,frames=frames)")

def prep_fit(path_pdb=pdb, path_xtc=xtc,syst=prot,form=lig,cv=cv,frames=frames,load=True):
    name = f'{syst}_{form}_{cv}'
    if load:
        load_trajs(path_pdb,path_xtc,name,skip=frames)
    
    #color
    cmd.color('white',f'polymer and elem C*')
    cmd.color('deepteal',f'resname UNK and elem C*')
    
    # dry
    cmd.remove('solvent or inorganic')

    # active site
    as_sele = select_AS(syst)
    cmd.select(f'act_site_{name}',f'resi {as_sele} and {name}')
    cmd.show('sticks',f'act_site_{name}')
    cmd.color('magenta',f'act_site_{name} and elem C*')
    cmd.disable(f'act_site_{name}')

    # oxyanion hole
    ox_sele = select_OX(syst)
    cmd.select(f'ox_hole_{name}',f'resi {ox_sele} and {name}')
    cmd.show('sticks',f'ox_hole_{name}')
    cmd.color('lightpink',f'ox_hole_{name} and elem C*')
    cmd.disable(f'ox_hole_{name}')

    # refine
    cmd.hide('everything',f'hydrogens')
    cmd.orient(f'resname UNK or act_site_{name}')
    cmd.center(f'act_site_{name} and resn SER')
    cmd.show('sticks',f'act_site_{name} and resn SER and sidechain or resn HIS and sidechain')

    # distances
    serOG  = f'act_site_{name} and resn SER and name OG'
    hisN   = f'act_site_{name} and resn HIS and name NE2'
    metN   = f'ox_hole_{name} and resn MET and name N'
    tyrN   = f'ox_hole_{name} and resn TYR and name N'
    ligC19 = f'name C19 and {name}'
    ligC39 = f'name C39 and {name}'
    ligC17 = f'name C17 and {name}'
    ligO7  = f'name O7 and {name}'
    cmd.distance(f'serO'  , serOG, ligC19, 5)
    cmd.distance(f'serhis', serOG, hisN  , 5)
    cmd.distance(f'sermet', serOG, metN  , 5)
    cmd.distance(f'sertyr', serOG, tyrN  , 5)
    cmd.distance(f'metN'  , metN , ligO7 , 5)
    cmd.distance(f'tyrN'  , tyrN , ligO7 , 5)
    cmd.color('green',f'ser*')

    cmd.deselect()
    cmd.orient(f'act_site_{name} and resn SER or ox_hole_{name} and resn MET or resname UNK and name C19')
    cmd.zoom(f'act_site_{name} or ox_hole_{name}')
    cmd.center(serOG)
    nstates = cmd.count_states()
    cmd.frame(nstates)

#load_fit(path_xtc=f'{lig}/cv_{cv}/mtd.fit.short_20.xtc',frames=10)
#load_fit(path_xtc=f'{lig}/cv_{cv}/mtd.fit.pdb',frames=10)

def prep_mol(selection="polymer"):
    cmd.set_view(view_prot)
    cmd.zoom('*',10)
    cmd.hide("sticks",selection=selection)
    cmd.hide("cartoon",selection=selection)
    cmd.show("surface",selection=selection)
    cmd.color("grey90",selection=selection)
    cmd.set('ray_opaque_background', 0)
    cmd.set('ray_shadow', 0)
    cmd.set('ray_trace_mode', 3)
    cmd.set('ray_trace_color', 'black')
    cmd.set('ray_trace_gain', 0.5)
    cmd.set('ambient', 0.5)
    cmd.set('light_count',1)
    cmd.set('surface_quality',2)

def save_mol(w=2400,h=2400,dpi=300,name='prot',outdir='figures/6eqe_2/media'):
    cmd.png(f"{outdir}/{name}.png",width=w,height=h,dpi=dpi,ray=1)
    print(f"figure saved as {outdir}/{name}.png res {w}x{h} dpi {dpi}")
