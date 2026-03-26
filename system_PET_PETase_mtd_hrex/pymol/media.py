#!/usr/bin/env python3
# -*- coding: UTF8 -*-

template_path="/home/adipede/projects/petase/templates/prot_prep"
reference_file="references_petase.py"

import sys
sys.path.append(template_path)
import pymol
from pymol import cmd

pymol.finish_launching()
cmd.run(f'{template_path}/{reference_file}')
cmd.run(f'pymol/variables.py')

def prep_fit(pdb=pdb,xtc=xtc,prot=prot,lig=lig,rep=rep,dir=dir,frames=frames,lstr=True,load=True):
    """load and prepare trajectory"""
    name = f'{lig}'
    # load
    if lstr: # load structure
        cmd.load(filename=pdb,object=name)
    # load traj
    if load:
        cmd.load_traj(filename=xtc,object=name,interval=frames)
    cmd.set_view(cat1)
    cmd.color('white',f'{name}')
    # dry
    cmd.remove('solvent or inorganic')
    # cat
    AS_sele  = f'resi  {select_AS(prot)} and {name}'
    cmd.show('sticks',        f'{AS_sele}')
    cmd.color('warmpink', f'{AS_sele} and elem C*') 
    cmd.color('atomic',       f'{AS_sele} and not elem C*') 

    OX_sele  = f'resi  {select_OX(prot)} and {name}'
    cmd.show('sticks',     f'{OX_sele}')
    cmd.color('salmon', f'{OX_sele} and elem C*') 
    cmd.color('atomic',    f'{OX_sele} and not elem C*') 

    TRP_sele = f'resi {select_TRP(prot)} and {name}'
    cmd.show('sticks',     f'{TRP_sele}')
    cmd.color('wheat', f'{TRP_sele} and elem C*') 
    cmd.color('atomic',    f'{TRP_sele} and not elem C*') 

    # lig
    cmd.color('lightteal',      f'resname UNK and {name} and elem C*')
    cmd.color('atomic',    f'resname UNK and {name} and not elem C*')

    # hydrogens
    cmd.hide('everything', f'hydrogens and {name}')
    cmd.hide('cartoon',f'{name}')

def gen_segms(name=name):
    AS_sele  = f'resi  {select_AS(prot)} and model {name}'
    OX_sele  = f'resi  {select_OX(prot)} and model {name}'
    TRP_sele = f'resi {select_TRP(prot)} and model {name}'
    wob_sele = f'resi {triad[prot][7][1]}'
    cmd.create(f'lig_{name}',f'resname UNK and model {name}')
    cmd.create(f'as_{name}' ,f'{AS_sele}  and model {name}')
    cmd.create(f'ox_{name}' ,f'{OX_sele}  and model {name}')
    cmd.create(f'trp_{name}',f'{TRP_sele} and model {name}')
    cmd.create(f'wob_{name}',f'{wob_sele} and model {name}')
    cmd.create(f'lig_trp',f'{TRP_sele} and model {name} or resname UNK and model {name}')
    cmd.create(f'prot',f'model {name} and polymer')

def dists(c=5,name=lig,prot=prot,discat=True,dispi=False,disuw=False):
    
    #name = f'{lig}'

    AS_sele  = f'resi  {select_AS(prot)} and model {name}'
    OX_sele  = f'resi  {select_OX(prot)} and model {name}'
    TRP_sele = f'resi {select_TRP(prot)} and model {name}'

    # distances
    serOG  = f'{AS_sele} and resn SER and name OG'
    hisNE  = f'{AS_sele} and resn HIS and name NE2'
    hisND  = f'{AS_sele} and resn HIS and name ND1'
    aspOD  = f'{AS_sele} and resn ASP and name OD2'

    metN   = f'{OX_sele} and resn MET and name N'
    tyrN   = f'resi {triad[prot][6][1][0]} and name N'
    tyrR   = f'byring resi {triad[prot][6][1][0]}'
    wobR   = f'byring resi {triad[prot][7][1]}'
    pistk  = f'byring resi {triad[prot][7][0][0]}'

    ligC19 = f'resname UNK and name C19 and model {name}'
    ligO7  = f'resname UNK and name O7  and model {name}'
    ligC39 = f'resname UNK and name C39 and model {name}'
    ligC17 = f'resname UNK and name C17 and model {name}'

    R1     = "+".join(str(a) for a in ring1 if a != " ")
    R2     = "+".join(str(a) for a in ring2 if a != " ")
    R3     = "+".join(str(a) for a in ring3 if a != " ")
    R4     = "+".join(str(a) for a in ring4 if a != " ")
    ligR1  = f'resname UNK and name {R1} and model {name}'
    ligR2  = f'resname UNK and name {R2} and model {name}'
    ligR3  = f'resname UNK and name {R3} and model {name}'
    ligR4  = f'resname UNK and name {R4} and model {name}'

    if discat:
        cmd.distance(f'ser_lig', serOG, ligC19, c)
        cmd.distance(f'ser_his', serOG, hisNE , c)
        cmd.distance(f'asp_his', aspOD, hisND , c)
        
        cmd.distance(f'ser_met', serOG, metN  , c)
        cmd.distance(f'ser_tyr', serOG, tyrN  , c)
        
        cmd.distance(f'met_lig', metN , ligO7 , c)
        cmd.distance(f'tyr_lig', tyrN , ligO7 , c)

    if dispi:
        #cmd.distance(f'wob_R1',  wobR,   ligR1, c, mode=4)
        cmd.distance(f'wob_R2',  wobR,   ligR2, c, mode=4)
        #cmd.distance(f'wob_R3',  wobR,   ligR3, c, mode=4)
        #cmd.distance(f'wob_R4',  wobR,   ligR4, c, mode=4)
        #
        #cmd.distance(f'pik_R1',  pistk,  ligR1, c, mode=4)
        #cmd.distance(f'pik_R2',  pistk,  ligR2, c, mode=4)
        cmd.distance(f'pik_R3',  pistk,  ligR3, c, mode=4)
        #cmd.distance(f'pik_R4',  pistk,  ligR4, c, mode=4)
        #
        #cmd.distance(f'tyr_R1',  tyrR,   ligR1, c, mode=4)
        cmd.distance(f'tyr_R2',  tyrR,   ligR2, c, mode=4)
        #cmd.distance(f'tyr_R3',  tyrR,   ligR3, c, mode=4)
        #cmd.distance(f'tyr_R4',  tyrR,   ligR4, c, mode=4)

    if disuw:
        cmd.distance(f'uwl_lig', ligC17, ligC39, c)

def prep_mol():
    cmd.set('ray_opaque_background', 0)
    cmd.set('ray_shadow', 0)
    cmd.set('ray_trace_mode', 3)
    cmd.set('ray_trace_color', 'black')
    cmd.set('ray_trace_gain', 0.5)
    cmd.set('ambient', 0.5)
    cmd.set('light_count',1)
    cmd.set('surface_quality',2)

def save_mol(w=2400,h=2400,dpi=300,name='prot',outdir='figures/media'):
    cmd.png(f"{outdir}/{name}.png",width=w,height=h,dpi=dpi,ray=1)
    print(f"figure saved as {outdir}/{name}.png res {w}x{h} dpi {dpi}")

def scene_eq2(name=name,view=eq2,suff='eq2',frame=38):
    cmd.frame(frame)
    cmd.delete('surf')
    cmd.delete('lig')
    cmd.set_view(view)
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_stick_{suff}', outdir='figures/6eqe_2/media')
    cmd.create('surf',f'{name} and not resname UNK')
    cmd.create('lig',f'{name} and resname UNK')
    cmd.disable(f'{name}')
    cmd.disable(f'lig')
    cmd.color('white',f'surf')
    cmd.hide('sticks',f'surf')
    cmd.show('surface',f'surf')
    cmd.set('transparency',0,f'surf')
    cmd.set_view(view)
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_surf_{suff}', outdir='figures/6eqe_2/media')
    # cat
    AS_sele  = f'resi  {select_AS(prot)} and surf'
    cmd.color('warmpink', f'{AS_sele}') 
    OX_sele  = f'resi  {select_OX(prot)} and surf'
    cmd.color('salmon', f'{OX_sele}') 
    TRP_sele = f'resi {select_TRP(prot)} and surf'
    cmd.color('wheat', f'{TRP_sele}') 
    cmd.hide('sticks', f'hydrogens and surf')
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_surf_color_{suff}', outdir='figures/6eqe_2/media')
    # cat
    cmd.set('transparency',0.2,f'surf')
    AS_sele  = f'resi  {select_AS(prot)} and surf'
    cmd.show('sticks',        f'{AS_sele}')
    cmd.color('warmpink', f'{AS_sele}') 
    OX_sele  = f'resi  {select_OX(prot)} and surf'
    cmd.show('sticks',     f'{OX_sele}')
    cmd.color('salmon', f'{OX_sele}') 
    TRP_sele = f'resi {select_TRP(prot)} and surf'
    cmd.show('sticks',     f'{TRP_sele}')
    cmd.color('wheat', f'{TRP_sele}') 
    cmd.hide('sticks', f'hydrogens and surf')
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_surf_color_stick_{suff}', outdir='figures/6eqe_2/media')
    cmd.hide('surface',f'surf')
    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_color_stick_{suff}', outdir='figures/6eqe_2/media')
    cmd.enable(f'lig')
    # lig
    cmd.color('lightteal',      f'resname UNK and lig')
    cmd.set_view(view)
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_surf_lig_{suff}', outdir='figures/6eqe_2/media')
    cmd.disable(f'surf')
    cmd.set_view(view)
#    save_mol(w=2400, h=2400, dpi=300, name=f'eq2_lig_{suff}', outdir='figures/6eqe_2/media')

# split long trj frames 
def split_each(sele,frames=25):
    print(f'# split states at max {frames} pts')
    nstates = cmd.count_states()    # count n frames
    splits = nstates / frames           # split max
    for state in range(1,nstates+1,int(splits)):
        cmd.split_states(f'{sele}',state,state) #,f'prefix')

# pulling
def pull_aln():
    prot   = f'6eqe'
    lig    = f'amor'
    rep    = f'0'
    frames = 10
    dir    = f'{lig}'
    pdb    = f'{dir}/eq2.dry.pdb'
    xtc    = f'{dir}/eq2.dry.short_10.xtc'
    name   = f'{lig}'
    ref    = f'../02_mineq'
    view   = pull

    prep_fit(pdb=pdb,xtc=xtc,prot=prot,lig=lig,rep=rep,dir=dir,frames=frames,lstr=True,load=False)
    cmd.load(filename=f'{ref}/ligcoord.pdb',object='ligcoord')
    cmd.load(filename=f'{ref}/ca_coord.pdb',object='ca_coord')
    cmd.load(filename=f'{ref}/ligxr.pdb',object='ligxr')
    cmd.hide('cartoon','ca_coord')
    cmd.show('ribbon','ca_coord')
    cmd.color('grey40','ca_coord')
    gen_segms()
    cmd.disable(f'*')
    cmd.enable(f'ca_coord or lig_{name} or ligcoord or ligxr')
    cmd.show('spheres','ca_coord and name CA')
    cmd.set('sphere_scale',0.1,selection='ca_coord')
    cmd.set('sphere_scale',0.3,selection='ligcoord')
    cmd.set('sphere_scale',0.3,selection=f'as_{name}')
    cmd.show('spheres','ligcoord and resname UNK')
    cmd.color('wheat','ligcoord and resname UNK and elem C*')
    cmd.color('wheat','ligxr and elem C*')
    cmd.enable(f'as_{name}')
    cmd.hide('sticks',f'as_{name}')
    cmd.show('lines',f'as_{name}')
    cmd.hide('everything','hydrogens')
    cmd.show('spheres',f'as_{name} and resname SER and name OG')
    cmd.set_view(view)
    cmd.zoom(f'resname UNK or as_{name}')

cmd.extend("prep_fit"   ,prep_fit)
cmd.extend("prep_mol"   ,prep_mol)
cmd.extend("save_mol"   ,save_mol)
cmd.extend("gen_segms"  ,gen_segms)
cmd.extend("dists"      ,dists)
cmd.extend("scene_eq2"  ,scene_eq2)
cmd.extend("split_each" ,split_each)
cmd.extend("pull_aln"   ,pull_aln)
