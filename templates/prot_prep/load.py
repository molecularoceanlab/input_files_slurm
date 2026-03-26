#!/usr/bin/env python3
# -*- coding: UTF8 -*-

#template_path="/home/adipede/projects/petase/templates/prot_prep"
template_path="templates/prot_prep"
reference_file="references_petase.py"
basics_file="basics_pymol.py"

import sys
sys.path.append(template_path)
import pymol
from pymol import cmd

pymol.finish_launching()
cmd.run(f'{template_path}/{reference_file}')
cmd.run(f'{template_path}/{basics_file}')

# default
#prot = f'7nei'
#lig = f'amor'
#cv = f'0'
#frames = 10
#pdb = f'{lig}/cv_{cv}/mtd.fit.pdb'
#xtc = f'{lig}/cv_{cv}/mtd.fit.xtc'
#name = f'{prot}_{lig}_{cv}'

#def load_fit(path_pdb=pdb, path_xtc=xtc,syst=prot,form=lig,cv=cv,frames=frames):
#def load_fit(path_pdb=pdb, path_xtc=xtc,syst=prot,name=name,frames=frames):
def load_fit(path_pdb=f'mtd.fit.pdb', \
             path_xtc=f'mtd.fit.xtc', \
             syst='7nei', frames=10, \
             name=f'7nei'):
    #name = f'{syst}_{form}_{cv}'
    load_trajs(path_pdb,path_xtc,name,skip=frames)
    
    #color
    cmd.color('white',f'polymer and elem C*')
    cmd.color('deepteal',f'resname UNK and elem C*')
    
    # dry
    cmd.remove('solvent or inorganic')

    # active site
    as_sele = select_AS(syst)
    #cmd.select(f'act_site_{name}',f'resi {as_sele} and {name}')
    #cmd.show('sticks',  f'act_site_{name}')
    #cmd.color('magenta',f'act_site_{name} and elem C*')
    as_sele_string = f'resi {as_sele} and {name}'
    cmd.show('sticks',  f'{as_sele_string}')
    cmd.color('magenta',f'{as_sele_string} and elem C*')
    #cmd.disable(f'act_site_{name}')

    # oxyanion hole
    ox_sele = select_OX(syst)
    ox_sele_string = f'resi {ox_sele} and {name}'
    cmd.show('sticks',  f'{ox_sele_string}')
    cmd.color('lightpink',f'{ox_sele_string} and elem C*')

    # pi stack
    pi_sele = select_TRP(syst)
    pi_sele_string = f'resi {pi_sele} and {name}'
    cmd.show('sticks',  f'{pi_sele_string}')
    cmd.color('lightorange',f'{pi_sele_string} and elem C*')

    # distances
    serOG  = f'{as_sele_string} and resn SER and name OG'
    hisN   = f'{as_sele_string} and resn HIS and name NE2 or {as_sele_string} and resn HID and name NE2'
    metN   = f'{ox_sele_string} and resn MET and name N'
#    tyrN   = f'{ox_sele_string} and resn TYR and name N' # not all tyr
    tyrN   = f'{ox_sele_string} and              name N and not resn MET'
    ligC19 = f'name C19 and {name}'
    ligC39 = f'name C39 and {name}'
    ligC17 = f'name C17 and {name}'
    ligO7  = f'name O7 and {name}'
    cmd.distance(f'serO_{name}'  , serOG, ligC19, 5)
    cmd.distance(f'serhis_{name}', serOG, hisN  , 5)
    cmd.distance(f'sermet_{name}', serOG, metN  , 5)
    cmd.distance(f'sertyr_{name}', serOG, tyrN  , 5)
    cmd.distance(f'metN_{name}'  , metN , ligO7 , 5)
    cmd.distance(f'tyrN_{name}'  , tyrN , ligO7 , 5)
    cmd.color('green',f'ser*')

    # refine
    cmd.hide('everything',f'hydrogens')
    cmd.show('lines',f'{as_sele_string} and resn HIS and sidechain')
    cmd.show('lines',f'{as_sele_string} and resn HID and sidechain')
    cmd.show('lines',f'{as_sele_string} and resn SER and sidechain')
    cmd.show('lines',f'{ox_sele_string} and backbone')
#    cmd.orient(f'resname UNK or act_site_{name}')
#    cmd.center(f'act_site_{name} and resn SER')
#    cmd.show('sticks',f'act_site_{name} and resn SER and sidechain or resn HIS and sidechain')
#    cmd.deselect()
#    cmd.orient(f'act_site_{name} and resn SER or ox_hole_{name} and resn MET or resname UNK and name C19')
#    cmd.zoom(f'act_site_{name} or ox_hole_{name}')
#    cmd.center(serOG)
    cmd.orient(f'{as_sele_string} and resn SER or {ox_sele_string} and resn MET or resname UNK and name C19')
    cmd.zoom(f'{as_sele_string} or {ox_sele_string}')
    cmd.center(serOG)
    nstates = cmd.count_states()
    cmd.frame(nstates)

def load_ref():
    cmd.load(f'../01_sysprep/xray_coords.pdb',f'ref_xray')
    cmd.load(f'../01_sysprep/lig_coords.pdb', f'ref_lig')
    #cmd.load(f'../01_sysprep/ref_coords.pdb', f'ref_syst')
    cmd.color('cyan',f'ref* and elem C*')

def help(func='load',syst='7nei',name='7nei',md='mtd',frames=10):
    if func == 'load':
        print(f'syst = f"{syst}"\nframes = f"{frames}"\npdb = f"{md}.fit.pdb"\nxtc = f"{md}.fit.xtc"\nname = f"{syst}"')
        print(f"load_fit(path_pdb=pdb, path_xtc=xtc,syst=syst,frames=frames,name=name)")
    elif func == 'sele':
        as_sele = select_AS(syst)
        as_sele_string = f'resi {as_sele} and {name}'
        print(as_sele_string)
        ox_sele = select_OX(syst)
        ox_sele_string = f'resi {ox_sele} and {name}'
        print(ox_sele_string)
        pi_sele = select_TRP(syst)
        pi_sele_string = f'resi {pi_sele} and {name}'
        print(pi_sele_string)


