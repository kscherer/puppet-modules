#!/bin/bash

num_ok=0
num_warning=0
num_critical=0
longoutput=

function email_me() {
    local instance=$1
	TMP_EMAIL=`mktemp -p /var/tmp hung_email.XXX`
    /etc/init.d/nx_instance.$instance tail > $TMP_EMAIL
    echo >> $TMP_EMAIL
    tail /home/nxadm/nx/${HOSTNAME}.${instance}/current_build/00-wrbuild.log >> $TMP_EMAIL
    git send-email --smtp-server prod-webmail.wrs.com --to konrad.scherer@windriver.com \
        --from nxadm@windriver.com \
        --subject "Server ${HOSTNAME}.${instance} is probably hung" $TMP_EMAIL
    rm $TMP_EMAIL
}

if [ -f /var/tmp/STFU ]; then
    if [ -f /home/nxadm/.disable_nagios_stfu_notification ]; then
        num_ok=1
        longoutput="SFTU Deployed and notification suppressed."
    else
        num_warning=1
        longoutput="SFTU Deployed"
    fi
else
    for instance in {1..4}; do
        nx=/etc/init.d/nx_instance.$instance
        if [ -a $nx ]; then
            output=$($nx status)
            if [ "$?" -eq "0" ]; then
                if [ "$output" == "Nx instance $instance is probably hung" ]; then
                    email_me $instance
                else
                    num_ok=$(($num_ok+1))
                fi
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
