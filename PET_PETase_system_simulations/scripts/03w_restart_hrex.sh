#!/usr/bin/env bash

source ~/.projects_startup.sh > /dev/null 2>&1

export OMP_NUM_THREADS=8

mpiexec -np 8 gmx_mpi mdrun -v -deffnm hrex -hrex -multidir r? -replex 500 -dlb no -cpt 60 -noappend -ntomp 8 -pin on -update cpu -nsteps 10 -plumed ../amor.dat -cpi hrex_prev.cpt
