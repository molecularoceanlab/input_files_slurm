
SHELL := zsh
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

outputs=target1 target2
.PHONY: help clean #  which targets are not represented by files

help:
	@echo "\e[4mTargets:\e[0m"
	@grep '^[[:alnum:]].*:' Makefile

DRY ?= '-n'
server='cesga'
exp='/mnt/lustre/scratch/nlsas/home/csic/eyg/sdp/007_HEMTx4_lwall_flex'

rsync_in:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude   '${server}:${exp}/*' .
rsync_out:
	rsync $(DRY) -a --update --info=progress2 -h --progress --exclude-from=exclude . '${server}:${exp}/'

#ratio:
#	./3_anal/dihedral_ratio.py > /tmp/ratio.tmp
#	echo -e "System\tTrans\tGauche\tRatio (t:g)\tlwall\tforce" > 3_anal/ratio.txt
#	for i in {01..19}; do at=$$(grep lwall 2_md/4_md/md_$$i/plumed_$$i.dat | awk '{split($$4,a,"="); split($$5,b,"="); printf "%.2f\t%.2f\n", a[2],b[2]}'); ratio=$$(grep md_$$i /tmp/ratio.tmp); echo -e "$$ratio\t$$at" >> 3_anal/ratio.txt ; done
#	cat 3_anal/ratio.txt

ratio:
	./3_anal/dihedral_ratio.py > 3_anal/ratio.txt 
	cat 3_anal/ratio.txt 
