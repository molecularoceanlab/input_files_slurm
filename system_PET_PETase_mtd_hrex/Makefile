SHELL := zsh
.ONESHELL:

ANIA ?= 'cesga'
FCO ?= 'fco_cesga'
DRY ?= '-n'
SYST ?= '6eqe_2'
LIG ?= 'amor'
XTC ?= 'hrex.xtc'
CV ?= 'd0'

aniapath='/mnt/lustre/scratch/nlsas/home/csic/eyg/sdp/027_bias'
fcopath='/mnt/lustre/scratch/nlsas/home/csic/qtc/fco/MOL/ania/027_bias/systs/6eqe_3_eq2_frozen'

# default commands
  
rsync_in:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude   '$(ANIA):${aniapath}/*' .
rsync_out:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude . '$(ANIA):${aniapath}/'
# FCO  
rsync_in_fco:
	rsync  $(DRY)  -a --update --info=progress2 -h --progress --exclude-from=systs/6eqe_3_eq2_frozen/exclude '$(FCO):${fcopath}/*' systs/6eqe_3_eq2_frozen/
rsync_out_fco:
	rsync $(DRY)   -a --update --info=progress2 -h --progress --exclude-from=systs/6eqe_3_eq2_frozen/exclude systs/6eqe_3_eq2_frozen/* '$(FCO):${fcopath}/'

squeue:
	ssh -t $(ANIA) << EOF
	squeue --format="%.10A %.10P %.20j %.10u %.4t %.12M %.6D %.20R"
	EOF

elapsed:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/03_production
		make elapsed LIG=$(LIG)
	EOF

wrap:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/03_production
		make wrap_hrex LIG=$(LIG)
	EOF

sumhills:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/04_analysis
		make sumhills_hrex LIG=$(LIG)
	EOF

reweight:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/04_analysis
		make reweight_hrex LIG=$(LIG) XTC=$(XTC)
	EOF

error:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/04_analysis
		make error LIG=$(LIG) CV=$(CV)
	EOF

torsions:
	ssh -t $(ANIA) << EOF
		cd ${aniapath}/systs/$(SYST)/04_analysis
		make torsions LIG=$(LIG) XTC=$(XTC)
	EOF
