#!/usr/bin/env bash

# DESCRIPTION
# submit slurm job for hrex equilibrium after pulling
# TEST 10 steps
# syst=7nei run=test
# cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02n_submit_hrex_lig.slurm $run $syst; cd ../../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02n_submit_hrex_lig.slurm $run $syst; cd ../../../../; fi; done
# RUN 30 hs
# run="test" syst="7nei" device="-update cpu" max="-nsteps 10 -maxh 0.1" time="0-00:10:00" arch=1
# run="run" syst="7nei" device="-update cpu -nb gpu" max="-maxh 0.15" time="0-00:10:00" arch=2
# run="run" syst="7nei" device="-update cpu -nb gpu" max="-maxh 1.45" time="0-01:30:00" arch=2
# run="run" syst="7nei" device="-update cpu -nb gpu" max="-maxh 0.15" time="0-00:10:00" arch="1_8"
# run="run" syst="6ths" device="-update cpu -nb gpu" max="-maxh 0.15" time="0-00:10:00" arch="2_2"
# cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02n_submit_hrex_lig.slurm "$run" "$syst" "$device" "$max" "$time" "$arch"; cd ../../../../
# for syst in $(ls systs); do if [ "$syst" != "6eqe" ]; then cd systs/$syst/02_mineq/hrex/; ../../../../scripts/02_mineq/02n_submit_hrex_lig.slurm "$run" "$syst" "$device" "$max" "$time" "$arch"; cd ../../../../; fi; done

source ~/.projects_startup.sh > /dev/null 2>&1

echo -e "
    $0 $@
    $pwd
"

nrep=8

# set default values if not given on 7nei on 4 nodes with 2 gpus
run=${1:-"test"}
syst=${2:-"7nei"}

if [[ "$run" == "test" ]]; then
	device=${3:-"-update cpu"}
	max=${4:-"-nsteps 10 -maxh 1.45"}
	time=${5:-"0-01:30:00"}
	arch=${6:-1}
	../../../../scripts/02_mineq/02m_run_hrex_lig.sh "$run" "$syst" "$device" "$max" "$time" "$arch" 

elif [[ "$run" == "run" ]]; then
	device=${3:-"-update cpu -nb gpu"}
	max=${4:-"-maxh 1.45"}
	time=${5:-"0-01:30:00"}
	arch=${6:-2}
	test_only=""	#"--test_only" # if set just test slurm script submission. leave empty

    # 8 tasks tot. ntasks per node = nreps / nnodes | cpus per tasks = 64 / ntasks per node.
    # set values for nodes
    #if [[ "$arch" -eq 8 ]]; then
    if [[ "$arch" == "1_8" ]]; then
        cp=8  mem=7500 n=1 gpus=8 ts=8 size=495     # only one node
    elif [[ "$arch" == "4_2" ]]; then
        cp=32 mem=3750 n=4 gpus=2 ts=2 size=247	# more nodes, quicker queue
    elif [[ "$arch" == "2_2" ]]; then
        cp=16  mem=3750 n=2 gpus=2 ts=4 size=247	# more nodes, quicker queue
    elif [[ "$arch" == "1_2" ]]; then
        cp=8  mem=3750 n=1 gpus=2 ts=8 size=247	# more nodes, quicker queue
    elif [[ "$arch" == "1_5" ]]; then
        cp=6  mem=7500 n=1 gpus=5 ts=8 size=495     # only one node
    fi

    echo -e "\nrun syst $syst hrex eq\n"
    echo -e "# GPUS x $arch x $n nodes $size G mem 64 cpus with $mem M per cpu and $cp per $ts task nrep $nrep"

#    sbatch ${test_only} \
    sbatch \
        -t $time \
        -N $n --gres=gpu:a100:${gpus} \
        --ntasks-per-node=${ts} \
        --cpus-per-task=${cp} \
        --mem-per-cpu=${mem}M \
        --job-name=${syst}_hrex_eq \
        --output=../../slurm/%x.%J.log \
        ../../../../scripts/02_mineq/02m_run_hrex_lig.sh "$run" "$syst" "$device" "$max" "$time" "$arch"
else
    echo -e "command line incomplete"
fi
