#!/bin/bash

# A post-build hook for nx which sends build stats to graphite
BDIR=$1
PASSFAIL=$2

#This is the graphite server TODO Make location aware
SERVER=yow-lpd-puppet2.wrs.com

#This is the graphite aggregator port
PORT=8125

#Track the build times for each config on each host
#CONFIG=$(basename $BDIR)

function send_data() {
    echo "$1" | nc -w 1 -u ${SERVER} ${PORT}
}

if [ $PASSFAIL == 0 ]; then
    echo "Send successful build stats to Graphite"

    #Build passed, send build success stat
    send_data "build_pass:1|c"
else
    echo "Send failed build stats to Graphite"

    #Build failed, send build failure stat
    send_data "build_fail:1|c"
fi

exit 0
