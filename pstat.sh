#!/bin/bash

#  -- Measure time, cpu and memory usage of a command

# Usage: ./pstat.sh COMMAND [ARGS]...

#

# Author: Sugesh Chandran <sugeshchandran@gmail.com>

# Created: 2019-Jan-02

############################################################################

# Copyright 2019 Sugesh Chandran.                                          #

#                                                                          #

# Licensed under the Apache License, Version 2.0 (the "License");          #

# you may not use this file except in compliance with the License.         #

# You may obtain a copy of the License at                                  #

#                                                                          #

#     http://www.apache.org/licenses/LICENSE-2.0                           #

#                                                                          #

# Unless required by applicable law or agreed to in writing, software      #

# distributed under the License is distributed on an "AS IS" BASIS,        #

# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #

# See the License for the specific language governing permissions and      #

# limitations under the License.                                           #

############################################################################
#Function to join an array element seperated by a specific delimiter.
function join_by()
{ local IFS="$1"; shift; echo "$*";
}

function main() {
    # Get the command to execute.
    echo "exectuing $@"
    STARTTIME=$(date +%s)
    cmd=( "$@" )
    # Execute the command in the background.
    "$@" &
    res_cpu=0.0
    res_mem=0.0
    while :
    do
        #Get all the child process for the script which is run in the session.
        # ****DO NOT RUN SAME PROCESS FROM SAME SESSION, IT WILL FAIL THE
        # THE SCRIPT TO GET RIGHT PROCESS IDs
        pids=$(ps --forest -o pid=,cmd= -g $(ps -o sid= -p $$) | \
               grep -v "grep" | grep -v $0 | grep -v "ps --forest -o pid=,cmd=")
        pids=$(echo "${pids[*]}"|awk 'NR>1{print $1}')
        pids=( $pids )
        numpids=${#pids[@]}

        #echo "number of active processes : $numpids"
        if [ "$numpids" -eq 0 ]; then
            break
        fi
        pids=$(join_by \| "${pids[@]}")
        mapfile -t res < <(ps -o pid,%cpu,%mem,cmd --noheader | grep -E "$pids" | awk '{print $2 " " $3}')
        sumcpu=0
        summem=0
        for data in "${res[@]}"
        do
            cpu=$(echo $data | head -n1 | awk '{print $1;}')
            mem=$(echo $data | head -n1 | awk '{print $2;}')
            sumcpu=$(echo " $sumcpu + $cpu " | bc -l)
            summem=$(echo " $summem + $mem " | bc -l)
        done
        echo "%CPU: $sumcpu, %MEM: $summem"
        if [ "$(echo " $res_cpu < $sumcpu " | bc -l)" == 1 ]; then
            res_cpu=$sumcpu
        fi
        if [ "$(echo " $res_mem < $summem " | bc -l)" == 1 ]; then
            res_mem=$summem
        fi
        sleep 1
        #Check again, if the process is still active.
    done
    ENDTIME=$(date +%s)
    echo "%CPU    :$res_cpu"
    echo "%memory :$res_mem"
    echo "time    : $(($ENDTIME - $STARTTIME))s"
}

main "$@"



