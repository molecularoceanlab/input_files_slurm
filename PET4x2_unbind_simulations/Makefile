SHELL := zsh
.ONESHELL:
# default commands

server='cesga'
folder='/mnt/lustre/scratch/nlsas/home/csic/eyg/sdp/026_PET_stuck'
DRY ?= '-n'
SYST ?= 'bb_UNK1_fixGC'
LIG ?= 'hr_a'
MD ?= 'hrex'

rsync_in:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude   '${server}:${folder}/*' .
rsync_out:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude . '${server}:${folder}/'

queue:
	ssh -t ${server} << EOF
	squeue --format="%.10A %.10P %.20j %.10u %.4t %.12M %.6D %.20R"
	EOF

elapsed:
	ssh -t ${server} << EOF
		cd ${folder}/systs/$(SYST)/03_production
		make elapsed LIG=$(LIG) MD=$(MD)
	EOF

