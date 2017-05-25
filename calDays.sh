#!/bin/bash 

export Path=/sbin:/usr/sbin:/bin:/usr/bin

echo "This program will try to calculate days between two days"

read -p "Please input the earlier day (YYYYMMDD ex>20170504): " startDate
read -p "Please input the later day (YYYYMMDD ex>20170504): " endDate

startDate_check=$(echo $startDate | grep '[0-9]\{8\}')
if [ "$startDate_check" == "" ]; then
    echo "You input the wrong input format..."
    exit 1
fi

endDate_check=$(echo $endDate | grep '[0-9]\{8\}')
if [ "$endDate_check" == "" ]; then
    echo "You input the wrong input format..."
    exit 1
fi

declare -i date_start=`date --date="$startDate" +%s`
declare -i date_end=`date --date="$endDate" +%s`
declare -i date_total_s=$(($date_end-$date_start))
declare -i date_d=$(($date_total_s/60/60/24))

echo "The $startDate and $endDate separated by $date_d days"
