#!/usr/bin/env bash

# DESCRIPTION
# sum hills 2d and 1d for traj
# syst=7nei lig=crys i=0
# cd systs/$syst/04_analysis/$lig/r0/; ../../../../../scripts/04_analysis/04d_reweight.sh; cd ../../../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then for lig in amor crys a350 c350; do 
# (cd systs/$syst/04_analysis/$lig/r0/; ../../../../../scripts/04_analysis/04d_reweight.sh; cd ../../../../../ ) & ;
# done; fi; done; wait

# for syst in $(ls systs); do for lig in a300 c300 a350 c350; do (cd systs/$syst/04_analysis/$lig/r0/; ../../../../../scripts/04_analysis/04d_reweight.sh; cd ../../../../../ ) & ; done; done; wait
# sbatch --job-name=${syst}_${lig}_reweight --time=00:15:00 --mem-per-cpu=3750M --nodes=1 --ntasks-per-node=16 --cpus-per-task=4 --output=../../../slurm/%x.%J.log

source ~/.projects_startup.sh > /dev/null 2>&1

sed -e "s/#RESTART/RESTART/" \
	-e "s/MOLINFO STRUCTURE=..\/..\/cluster.pdb/MOLINFO STRUCTURE=..\/..\/..\/03_production\/cluster.pdb/" \
    -e '/^COM         LABEL=C0/ s/^/#/' \
    -e '/^DISTANCE    LABEL=d2/ s/^/#/' \
    -e '/^ANGLE       LABEL=a0/ s/^/#/' \
    -e '/^DRMSD       LABEL=drms0/ s/^/#/' \
    -e '/^FIXEDATOM  LABEL=a1/  s/^/#/' \
    -e '/^DISTANCE   LABEL=d3/  s/^/#/' \
	-e 's/HEIGHT=[0-9.]\+/HEIGHT=0.0/' \
	-e 's/PACE=[0-9.]\+/PACE=10000000/g' \
	-e '/^\.\.\.$/i \\tFILE=HILLS' \
	-e 's/STRIDE=1000/STRIDE=1/g' \
	-e 's/FILE=colvar/FILE=colvar.reweight/g' mtd.dat > mtd_reweight.dat

cat << EOF >> mtd_reweight.dat
### reweight histograms
as: REWEIGHT_BIAS ARG=metad.bias TEMP=298
hd0: HISTOGRAM ARG=d0 LOGWEIGHTS=as BANDWIDTH=0.01 GRID_MIN=0.0 GRID_MAX=1.2 GRID_BIN=200
h0d: HISTOGRAM ARG=d0,h0 LOGWEIGHTS=as BANDWIDTH=0.01,0.01 GRID_MIN=0.0,0.0 GRID_MAX=1.2,1.4 GRID_BIN=200,200
h1d: HISTOGRAM ARG=d0,h1 LOGWEIGHTS=as BANDWIDTH=0.01,0.01 GRID_MIN=0.0,0.0 GRID_MAX=1.2,1.4 GRID_BIN=200,200 

fd0: CONVERT_TO_FES GRID=hd0 TEMP=298
f0d: CONVERT_TO_FES GRID=h0d TEMP=298
f1d: CONVERT_TO_FES GRID=h1d TEMP=298

DUMPGRID GRID=fd0 FILE=fd0.dat
DUMPGRID GRID=f0d FILE=f0d.dat
DUMPGRID GRID=f1d FILE=f1d.dat

hh0: HISTOGRAM ARG=h0 LOGWEIGHTS=as BANDWIDTH=0.01 GRID_MIN=0.0 GRID_MAX=1.4 GRID_BIN=200
hh1: HISTOGRAM ARG=h1 LOGWEIGHTS=as BANDWIDTH=0.01 GRID_MIN=0.0 GRID_MAX=1.4 GRID_BIN=200
h2h: HISTOGRAM ARG=h0,h1 LOGWEIGHTS=as BANDWIDTH=0.01,0.01 GRID_MIN=0.0,0.0 GRID_MAX=1.4,1.4 GRID_BIN=200,200

fh0: CONVERT_TO_FES GRID=hh0 TEMP=298
fh1: CONVERT_TO_FES GRID=hh1 TEMP=298
f2h: CONVERT_TO_FES GRID=h2h TEMP=298

DUMPGRID GRID=fh0 FILE=fh0.dat
DUMPGRID GRID=fh1 FILE=fh1.dat
DUMPGRID GRID=f2h FILE=f2h.dat
EOF

for file in colvar.reweight fd0.dat f0d.dat f1d.dat fh0.dat fh1.dat f2h.dat; do
    if [[ -f "$file" ]]; then
        echo removing previous $file
        rm $file
    else echo reweighting $file
    fi
done

plumed driver --plumed mtd_reweight.dat --mf_xtc hrex.xtc

rm *bck.*
