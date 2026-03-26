from pymol import cmd
import glob

selection = 'pet*'
file_crys = '../026_PET_stuck/systs/bb_UNK1_fixGC/03_production/crys/mtd.fit'

view = (
     1.000000000,    0.000000000,    0.000000000,
     0.000000000,    1.000000000,    0.000000000,
     0.000000000,    0.000000000,    1.000000000,
     0.000000000,    0.000000000,  -69.145164490,
    48.850017548,   49.201549530,   23.055231094,
    54.514575958,   83.775756836,  -20.000000000 )

def load_tors(s=0,e=19,w=1,rate=1):
    for i in range(s,e,w):
        basepath = f"2_md/4_md/md_{str(i+1).zfill(2)}/step06_md1_{str(i+1).zfill(2)}"
        name = f"pet{str(i+1).zfill(2)}"
        align = f"pet{str(s+1).zfill(2)}"
        print(s,e,w,basepath,name,align)
        cmd.load(f"{basepath}.dry.start.pdb",object=name)
        cmd.load_traj(f"{basepath}.dry.fit.xtc",object=name,interval=rate)
        cmd.intra_fit(name)
        cmd.extra_fit(name,align) 

def prep_mol(view=view,selection=selection):
    cmd.set_view(view)
    cmd.frame(500)
    cmd.set('stick_ball',1,selection=selection)
    cmd.set('stick_ball_ratio',2,selection=selection)
    cmd.set('sphere_scale',0.25,selection=selection)
    cmd.set('stick_ball_color','atomic',selection=selection)
    cmd.set('stick_radius',0.2,selection=selection)
    cmd.set('stick_color','atomic',selection=selection)
    cmd.set('valence',1) # double bonds
    cmd.orient()
    cmd.spectrum("model", "violetpurple hotpink lightmagenta pink lightpink wheat palecyan aquamarine teal deepteal grey30", minimum=-0.5, maximum=20, byres=1)
    # cmd.spectrum("model", "hotpink wheat deepteal", minimum=0, maximum=19, byres=1)
    # cmd.spectrum("model", "chocolate firebrick orange wheat aquamarine teal deepteal grey30", minimum=-1, maximum=20, byres=1)
    # cmd.spectrum("model", "warmpink wheat deepteal", byres=1)
    # spectrum model, raspberry warmpink wheat deepteal grey30
    # spectrum model, firebrick orange wheat deepteal grey50
    # spectrum model, firebrick orange gold wheat grey70 deepteal
    # spectrum model, firebrick orange wheat grey50 deepteal grey30
    # purple hotpink lightpink  wheat turquoise teal darkslategrey
    # firebrick darkorange orange  wheat turquoise teal darkslategrey
    # custom_pink   = ["purple", "hotpink", "lightpink" , "wheat", "turquoise", "teal", "darkslategrey"]
    # custom_orange = ["firebrick", "darkorange", "orange" , "wheat", "turquoise", "teal", "darkslategrey"]


    cmd.set('antialias',2)
    cmd.set('ray_opaque_background', 0)
    cmd.set('ray_shadow', 0)
    cmd.set('ray_trace_mode', 3)
    cmd.set('ray_trace_color', 'black')
    cmd.set('ray_trace_gain', 0.5)
    cmd.set('ambient', 0.5)
    cmd.set('light_count',1)

def save_mol(l=1200,h=600,name='pet_torsions'):
    cmd.png(f"figures/{name}.png",width=l,height=h,dpi=600,ray=1)
    print(f'file saved figures/{name}.png {l}x{h}')

# set grid_mode, 1
# set grid_max,  15

def save_loop(l=1200,h=400,name='pet',s=0,e=19,w=1):
    for i in range(s,e,w):
        cmd.orient('*')
        cmd.zoom('*',-10)
        cmd.ray(l,h)
        cmd.disable('*')
        cmd.enable(f'pet{str(i+1).zfill(2)}')
        cmd.ray(l,h)
        cmd.png(f"{name}_{i+1}.png",width=l,height=h,ray=1)
        print(f'file saved {name}_{i+1}.png {l}x{h}')
