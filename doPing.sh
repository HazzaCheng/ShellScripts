#!/bin/bash 

export Path=/sbin:/usr/sbin:/bin:/usr/bin

network=10.10.65

for sitenu in $(seq 1 100)
do
    ping -c 1 -w 1 ${network}.${sitenu} &> /dev/null && result=0 || result=1
    if [ "$result" == 0 ]; then
        echo "${network}.${sitenu} is UP"
    else
        echo "${network}.${sitenu} is DOWN"
    fi
done
