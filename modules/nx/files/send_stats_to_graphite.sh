#!/bin/bash

# A post-build hook for nx which sends build stats to graphite
BDIR=$1
PASSFAIL=$2

#This is the graphite server TODO Make location aware
SERVER=yow-lpd-monitor

#This is the graphite aggregator port
PORT=2023

#timestamp used for all stats sent to graphite
NOW=$(date +%s)

#Track the build times for each config on each host
CONFIG=$(basename $BDIR)
METRIC_BASE="nx.${HOSTNAME}.${CONFIG}"

function send_data() {
    METRIC_NAME=$1
    METRIC_VALUE=$2
    echo "$1 $2 $NOW" | nc ${SERVER} ${PORT}
}

if [ $PASSFAIL == 0 ]; then
    #Build passed, send build success stat
    send_data "${METRIC_BASE}.success" "1"

    #Log the time to complete build
    BUILD_TIME=$(cat $BDIR/time.log)
    send_data "${METRIC_BASE}.time" "${BUILD_TIME}"
else
    #Build failed, send build failure stat
    send_data "${METRIC_BASE}.failure" "1"
fi

exit 0
