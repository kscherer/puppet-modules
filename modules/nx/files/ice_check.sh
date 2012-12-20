#!/bin/bash

FAIL=$1
#TOP=$2
#DEFAULT_BRANCH=$3

if [ -f $FAIL/00-wrbuild.log ]; then
    grep -qF -e 'Segmentation fault' -e 'internal compiler error:' -e 'Your Makefile has been rebuilt' $FAIL/00-wrbuild.log 2>/dev/null
    if [ $? = 0 ]; then
        #It looks like this build failed due to an ICE, either hardware or VM related
        #Do not clutter the nx fail repo with this build
        exit 1
    fi
fi
exit 0
