#!/usr/bin/env python3
# -*- coding: UTF8 -*-

template_path="/home/adipede/projects/petase/templates/prot_prep"
template_file="references_petase.py"

import sys, os
sys.path.append(template_path)
import references_petase as ref
import pymol
from pymol import cmd

# https://pymolwiki.org/index.php/Launching_From_a_Script
#   # autocompletion
#   import readline
#   import rlcompleter
#   readline.parse_and_bind('tab: complete')
#   # pymol launching: quiet (-q), without GUI (-c) and with arguments from command line, fullscreen (-e)
#   import pymol
#   pymol.pymol_argv = ['pymol','-qc'] + sys.argv[1:]
#   pymol.finish_launching()
#   cmd = pymol.cmd

# PYTHON FUNCTIONS

# Function to translate three-letter code to one-letter code
def translate_to_one_letter(three_letter_code):
    return ref.aa_3to1.get(three_letter_code.upper(), 'Unknown')

# Function to translate one-letter code to three-letter code
def translate_to_three_letter(one_letter_code):
    return ref.aa_1to3.get(one_letter_code.upper(), 'Unknown')

def select_AS(prot):
    print(f'\n# show active site for {prot}:')
    print(f'ser his asp')
    print(ref.triad[prot][1])
    aa_list = ref.triad[prot][1]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_OX(prot):
    print(f'\n# show oxyanion hole for {prot}:')
    print(f'met {ref.triad[prot][6][1][1].lower()}') # 'met tyr/phe'
    print(ref.triad[prot][6])
    aa_list = [ref.triad[prot][6][0],ref.triad[prot][6][1][0]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_TRP(prot):
    print(f'\n# show trp or his pi-stack for {prot}:')
    print(f'{ref.triad[prot][7][0][1].lower()} trp') # 'trp/his trp'
    print(ref.triad[prot][7])
    aa_list = [ref.triad[prot][7][1],ref.triad[prot][7][0][0]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

def select_CYS(prot):
    print(f'\n# show cys s-s bridge for {prot}:')
    print(f's-s1 s-s2 if present') # 'cys-cys'
    print(ref.triad[prot][4],ref.triad[prot][5])
    aa_list = [ref.triad[prot][4],ref.triad[prot][5]]
    aa_sele = "+".join(str(aa) for aa in aa_list if aa != " ")
    return aa_sele

# PYMOL FUNCTIONS

print(f'# transparent background high quality images')
cmd.set('ray_opaque_background', 0)

print(f'# load big trajectories lighter mode')
cmd.set('defer_builds_mode', 3)

# load trajs
def load_trajs(path_pdb,path_xtc,name,skip=1):
    print(f'# load trajs {path_pdb} {path_xtc} {name}')
    cmd.load(f'{path_pdb}',name)
    cmd.load_traj(f'{path_xtc}', state=1, interval=skip, object=name)

# format polymer and small molecules
def color_complex(sele):
    print(f'# format molecules grey')
    cmd.hide('everything',selection='hydrogens')
    cmd.color('deepteal',selection=f'{sele} and organic and elem C*')
    cmd.color('grey90',selection=f'{sele} and polymer and elem C*')
    cmd.color('atomic',selection=f'{sele} and not elem C*')

# format polymer 2 and small molecules 2
def color_complex2(sele):
    print(f'# format molecules grey')
    cmd.hide('everything',selection='hydrogens')
    cmd.color('lightteal',selection=f'{sele} and organic and elem C*')
    cmd.color('grey60',selection=f'{sele} and polymer and elem C*')
    cmd.color('atomic',selection=f'{sele} and not elem C*')

# split long trj frames 
def split_each(sele,frames=25):
    print(f'# split states at max {frames} pts')
    nstates = cmd.count_states()    # count n frames
    splits = nstates / frames           # split max
    for state in range(1,nstates+1,int(splits)):
        cmd.split_states(f'{sele}',state,state) #,f'prefix')

def load_petase_complex(path,syst,prot):
    load_trajs(path,syst)
    color_complex(syst)

    # pulling points
    as_sele = ref.select_AS(prot)
    cmd.select(f'act_site_{syst}',f'resi {as_sele} and {syst}')
    cmd.show('sticks',f'act_site_{syst}')
    cmd.color('magenta',f'act_site_{syst} and elem C*')

    ox_sele = ref.select_OX(prot)
    cmd.select(f'ox_hole_{syst}',f'resi {ox_sele} and {syst}')
    cmd.show('sticks',f'ox_hole_{syst}')
    cmd.color('lightpink',f'ox_hole_{syst} and elem C*')

    # distances
    serOG = f'act_site_{syst} and resn SER and name OG'
    metN = f'ox_hole_{syst} and resn MET and name N'
    tyrN = f'ox_hole_{syst} and resn TYR and name N'
    ligC19 = f'name C19 and {syst}'
    ligC39 = f'name C39 and {syst}'
    ligC17 = f'name C17 and {syst}'
    ligO7  = f'name O7 and {syst}'
    cmd.distance(f'pull_{syst}', serOG, ligC19, 10)
    cmd.distance(f'metN_{syst}', metN, ligO7, 10)
    cmd.distance(f'tyrN_{syst}', tyrN, ligO7, 10)
    cmd.color('green',selection=f'pull*')

    cmd.deselect()
    cmd.hide('everything','hydrogens')
    nstates = cmd.count_states()
    cmd.frame(nstates)
#    cmd.orient(f'*act_site* or *ox_hole* or resname UNK')

def movie_settings(syst='6eqe', form='amor'):
    # prepare structure
    cmd.extract('lig', f'{syst}_{form} and resname UNK')
    cmd.extract('act', f'{syst}_{form} and act_site_{syst}_{form} and sidechain')
    cmd.extract('ox', f'{syst}_{form} and ox_hole_{syst}_{form} and sidechain')
    cmd.orient('all around 4 act or ox')
    cmd.zoom('lig')
    cmd.center('all')
    cmd.show('surface',f'{syst}_{form}')
    cmd.color('grey90',f'{syst}_{form}')
    cmd.color('lightpink',f'{syst}_{form} and ox_hole_{syst}_{form}')
    cmd.color('magenta',f'{syst}_{form} and act_site_{syst}_{form}')
    #prepare movie
    # Set up movie settings
    cmd.set_view(view_dict[f'{prot}']) # set view for protein
    cmd.set("ray_opaque_background", "off")  # Transparent background
    cmd.set("ray_scatter", "off")  # 
    cmd.bg_color('white')  # Change background color
    cmd.viewport(1080, 1080)  # Set square viewport
    cmd.set('antialias', 2) # smoothing edges of the objects for quality up to 5, slows rendering
#    cmd.set('ray_trace_dpi', dpi)  # Set high DPI
    cmd.set('ray_shadow', 'off')
    cmd.set('ray_trace_gain', 0)
    cmd.set('ray_trace_mode', 3)

def generate_video(syst='6eqe', form='amor', dpi=300, output='test', movie_duration=15, fps=24):

    total_states = cmd.count_states()
    # Subsample the trajectory to reduce memory load
    subsample_rate = max(1, total_states // (fps * movie_duration))  # Calculate subsampling rate to fit within the 15-second limit
    frames = " ".join([str(i) for i in range(1, total_states + 1, subsample_rate)])
    cmd.mset(frames)  # Set subsampled states

    # Reinterpolate the frames for smooth transitions
    cmd.mview('reinterpolate')

    total_frames = cmd.count_frames()

    # Prepare the movie
    for i in range(1, total_frames + 1):
        cmd.frame(i)
        cmd.ray()  # Ray trace for high-quality rendering
        cmd.png(f"{syst}/{form}/movie/{output}_{i:04d}.png", dpi=dpi)  # Save each frame as PNG

    #print(f"Generated {total_frames} frames for a {movie_duration}-second movie at {fps} fps.")

    # Calculate frame rate based on total frames and desired movie duration
    frame_rate = total_frames / movie_duration

    # Generate the video using FFmpeg
    ffmpeg_command = f"ffmpeg -framerate {frame_rate} -i {syst}/{form}/movie/{output}_%04d.png -c:v libx264 -pix_fmt yuv420p {syst}/{form}/movie/{output}.mp4"
    os.system(ffmpeg_command)

    print(f"Generated {total_frames} frames for a {movie_duration}-second movie at {frame_rate:.2f} fps.")
    print(f"Video saved as {output}.mp4")

# Prepare the trajectory
#load_fit(traj, prot, lig, skip=1)
#generate_video(syst=prot,form=lig,skip=10, dpi=300, output=prot)

# Movie creation is finished, now you can use FFmpeg externally to convert the images to a video
# frame_rate = total_frames / movie_duration # frame_rate = total_frames / 15
# ffmpeg -framerate 24 -i test114_%04d.png -c:v libx264 -pix_fmt yuv420p test1.mp4
# reinitialize
