####################

	rotational analysis of ligand 4HEMT into water using 
	plumed lower wall restraints strategy
	28 mar 2022

####################


        --->>>          SECTION E       <<<---

###	ANALYSISi
###	07 abr 2022

-> automate gnuplot generation of outputs
-> matplotlib ¿¿¿
-> automate pymol file upload using script

cesga has spider and all python data menagment packages

module spider gnuplot, pandas, matplotlib, ext...

      cesga/2018  gcccore/6.4.0

        module load gcccore/6.4.0 gnuplot/5.2.7
        gnuplot

  gnuplot: gnuplot/5.2.7

gnuplot

	G N U P L O T
	Version 5.2 patchlevel 8    last modified 2019-12-01 

	Copyright (C) 1986-1993, 1998, 2004, 2007-2019
	Thomas Williams, Colin Kelley and many others

	gnuplot home:     http://www.gnuplot.info
	faq, bugs, etc:   type "help FAQ"
	immediate help:   type "help"  (plot window: hit 'h')

Terminal type is now 'qt'
gnuplot> set style line 1 \
>    linecolor rgb '#0060ad' \
>    linetype 1 linewidth 2 \
>    pointtype 7 pointsize 1.5
gnuplot> plot '1_min/step03_min1.xvg' with linespoints linestyle 1
gnuplot> 
gnuplot> plot '2_md/4_md/COLVAR' using 1:2 w linepoints linestyle 1, '2_md/4_md/COLVAR' using 1:3 with linepoints linestyle 2, '2_md/4_md/COLVAR' using 1:4 with linepoints linestyle 3




http://hirophysics.com/gnuplot/gnuplot13.html


http://www.gnuplotting.org/plotting-data/

gnuplot> set style line 1 \
>    linecolor rgb '#0060ad' \
>    linetype 1 linewidth 2 \
>    pointtype 7 pointsize 1.5
gnuplot> set style line 2 \
>    linecolor rgb '#dd181f' \
>    linetype 1 linewidth 2 \
>    pointtype 5 pointsize 1.5
gnuplot> set style line 3 \
>    linecolor rgb '#77ac30' \
>    linetype 1 linewidth 2 \
>    pointtype 3 pointsize 1.5


pymol:

load 2_md/4_md_05/step06_md1_05.start.pdb, 00_27 \
load_traj 2_md/4_md_05/step06_md1_05.fit.xtc, 00_27 \
remove solvent \
intra_fit 00_27 \
pair_fit 00_27///UNK/C17, 00_37///UNK/C17, 00_27///UNK/C39, 00_37///UNK/C39, \
orient \
smooth

        >>>     xxx.file      <<<
                                                                #top
############################################################

############################################################
                                                                #bot
