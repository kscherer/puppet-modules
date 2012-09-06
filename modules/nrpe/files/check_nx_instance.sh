#!/bin/bash

num_ok=0
num_warning=0
num_critical=0
longoutput=

if [ -f /var/tmp/STFU ]; then
    num_warning=1
    longoutput="SFTU Deployed"
else
    for instance in {1..4}; do
        nx=/etc/init.d/nx_instance.$instance
        if [ -a $nx ]; then
            output=$($nx status)
            if [ "$?" -eq "0" ]; then
                num_ok=$(($num_ok+1))
            elif [ "$?" -eq "1" ]; then
                num_warning=$((num_warning+1))
                longoutput="$longoutput\n$output"
            elif [ "$?" -eq "151" ]; then
                num_warning=$((num_warning+1))
                longoutput="$longoutput\n$output"
            elif [ "$?" -eq "3" ]; then
                num_critical=$(($num_critical+1))
                longoutput="$longoutput\n$output"
            elif [ "$?" -eq "4" ]; then
                num_critical=$(($num_critical+1))
                longoutput="$longoutput\n$output"
            fi
        fi
    done
fi

total=$(($num_ok+$num_warning+$num_critical))

echo "OK: $num_ok WARNING: $num_warning CRITICAL: $num_critical UNKNOWN: 0|total=$total ok=$num_ok warn=$num_warning
 crit=$num_critical unknown=0 $longoutput"

if [ "$num_critical" -gt "0" ]; then
    exit 2
elif [ "$num_warning" -gt "0" ]; then
    exit 1
else
    exit 0
fi
