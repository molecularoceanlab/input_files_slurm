#!/usr/bin/env python3
# -*- coding: UTF8 -*-

view_all = (
     1.000000000,    0.000000000,    0.000000000,
     0.000000000,    1.000000000,    0.000000000,
     0.000000000,    0.000000000,    1.000000000,
     0.000000000,    0.000000000, -506.433197021,
    64.552040100,   64.727813721,   45.137832642,
   399.275787354,  613.590576172,  -20.000000000 )

view_double = (
     0.510486484,   -0.469725758,   -0.720250845,
    -0.003454734,    0.836485088,   -0.547978818,
     0.859878838,    0.282224059,    0.425391555,
     0.000000000,    0.000000000, -115.783348083,
    64.034370422,   64.165466309,   45.545730591,
    91.284469604,  140.282226562,  -20.000000000 )

view_single = (
     0.508202970,   -0.345363170,   -0.788957715,
     0.002136093,    0.916577160,   -0.399852157,
     0.861234725,    0.201520756,    0.466544956,
    -0.000008285,    0.000004441,  -60.213432312,
    58.526229858,   61.375717163,   48.789093018,
    36.727188110,   83.699790955,  -20.000000000 )


view_4 = (
     0.407299697,    0.547323406,   -0.731124282,
    -0.018645188,    0.805350542,    0.592501998,
     0.913102150,   -0.227694452,    0.338224381,
     0.000000000,    0.000000000, -108.096260071,
    64.034370422,   64.165466309,   45.545730591,
   -10.898292542,  227.090820312,  -20.000000000 )

view_crys_start = (
     0.457577914,   -0.119420804,    0.881113410,
     0.035641320,   -0.987680376,   -0.152373701,
     0.888455391,    0.101126753,   -0.447684675,
     0.000000000,    0.000000000,  -73.068084717,
    64.036148071,   64.164291382,   45.543876648,
    50.360282898,   95.776123047,  -20.000000000 )

name='crys'
pdb='crys/mtd.fit.pdb'

def load_simple(pdb=pdb,name=name):
    cmd.load(pdb,name)
    cmd.remove(f'solvent or inorganic and {name}')

def scene_single(name=name):
    selection = f'resname UNK and chain A and {name}'
    cmd.set_view(view_single)
    cmd.orient(f'resname UNK and chain A and {name}')
    cmd.zoom(f'resname UNK and chain A and {name}')
    cmd.hide('everything',f'{name} and not chain A')
    cmd.color('deepteal',f'{name} and resname UNK and chain A and elem C*')
    cmd.show('sticks',f'{selection}')
    cmd.show('spheres',f'{selection}')
    cmd.set('stick_ball',1,selection=selection)
    cmd.set('stick_ball_ratio',2,selection=selection)
    cmd.set('sphere_scale',0.1,selection=selection) # 0.25
    cmd.set('stick_ball_color','atomic',selection=selection)
    cmd.set('stick_radius',0.2,selection=selection)
    #cmd.set('stick_color','atomic',selection=selection)
    #set valence, 1 # double bonds

    cmd.set('ray_opaque_background', 0)
    cmd.set('ray_shadow', 0)
    cmd.set('ray_trace_mode', 3)
    cmd.set('ray_trace_color', 'black')
    cmd.set('ray_trace_gain', 1)
    cmd.set('ambient', 0.5)
    cmd.set('light_count',1)

def scene_all(name=name):
    selection = f'resname UNK and {name}'
    selection0 = f'resname UNK and chain A and {name}'
    cmd.set_view(view_all)
    cmd.zoom(f'{selection0}', -7)
    cmd.color('deepteal',  f'{name} and resname UNK and chain A and elem C*')
    cmd.color('lightpink', f'{name} and resname UNK and chain B and elem C*')
    cmd.show('sticks',f'{selection}')
    cmd.show('spheres',f'{selection}')
    cmd.set('stick_ball',1,selection=selection)
    cmd.set('stick_ball_ratio',2,selection=selection)
    cmd.set('sphere_scale',0.25,selection=selection)
    cmd.set('stick_ball_color','atomic',selection=selection)
    cmd.set('stick_radius',0.2,selection=selection)
    #cmd.set('stick_color','atomic',selection=selection)
    #set valence, 1 # double bonds

    cmd.set('ray_opaque_background', 0)
    cmd.set('ray_shadow', 0)
    cmd.set('ray_trace_mode', 3)
    cmd.set('ray_trace_color', 'black')
    cmd.set('ray_trace_gain', 1)
    cmd.set('ambient', 0.5)
    cmd.set('light_count',1)

def split_each(sele,frames=25):
    print(f'# split states at max {frames} pts')
    nstates = cmd.count_states()    # count n frames
    splits = nstates / frames           # split max
    for state in range(1,nstates+1,int(splits)):
        cmd.split_states(f'{sele}',state,state) #,f'prefix')

def save_fig(name=name,w=1200,h=900):
    cmd.png(f'figures/bb/{name}.png', width=w, height=h, dpi=300, ray=1)
    print(f'figure saved: figures/bb/{name}.png {w}x{h}')

def save_loop(name=name,l=1200,h=900,s=1,e=100,w=1):
    fr = cmd.count_frames(name)
    for i in range(s,e,w):
        print(fr,i,s,e,w)
        cmd.frame(i)
        cmd.png(f'figures/bb/{name}_{i}.png', width=l, height=h, dpi=300, ray=1)
        print(f' figure saved as {l}x{h} figures/bb/{name}_{i}.png')

def generate_video(dpi=300, output='test', movie_duration=15, fps=24):

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
        print(f'saved image figures/bb/movie/{output}_{i:04d}.png')
        cmd.frame(i)
        cmd.ray()  # Ray trace for high-quality rendering
        cmd.png(f"figures/bb/movie/{output}_{i:04d}.png", dpi=dpi)  # Save each frame as PNG

    #print(f"Generated {total_frames} frames for a {movie_duration}-second movie at {fps} fps.")

    # Calculate frame rate based on total frames and desired movie duration
    frame_rate = total_frames / movie_duration

    # Generate the video using FFmpeg
    ffmpeg_command = f"ffmpeg -framerate {frame_rate} -i figures/bb/movie/{output}_%04d.png -c:v libx264 -pix_fmt yuv420p figures/bb/movie/{output}.mp4"
    os.system(ffmpeg_command)

    print(f"Generated {total_frames} frames for a {movie_duration}-second movie at {frame_rate:.2f} fps.")
    print(f"Video saved as {output}.mp4")

# Movie creation is finished, now you can use FFmpeg externally to convert the images to a video
# frame_rate = total_frames / movie_duration # frame_rate = total_frames / 15
# ffmpeg -framerate 24 -i test114_%04d.png -c:v libx264 -pix_fmt yuv420p test1.mp4
# reinitialize
