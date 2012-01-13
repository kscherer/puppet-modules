#!/bin/sh

user=$(whoami)
if [ "$user" !=  "buildadmin" ]; then
    echo "Must be user buildadmin"
    exit 1
fi
hostname=$(hostname)
cd /home/buildadmin
#ulimit -c unlimited
ulimit -u 400
notxylo/nx --rcfile ~/nxrc_files/$hostname > ~/log/nx.log 2>&1 &
