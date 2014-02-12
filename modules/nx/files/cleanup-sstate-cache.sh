#!/bin/bash

base=/home/nxadm

if [ ! -d $base/nx/sstate_cache ]; then
    exit 0
fi

#retrieve wrlinux branch as set in nxrc files
nxrc_file=$base/nx/${HOSTNAME}.1/nxrc_files/${HOSTNAME}.1
if [ -f $nxrc_file ]; then
    branch=$(grep DEFAULT_BRANCH= $nxrc_file | cut -d= -f 2)
else
    echo "nxrc file not found. Not running on nxbuilder"
    exit 1
fi

wrlinux_dir=$base/nx/${HOSTNAME}.1/wrlinux-x

#special case for master branch which does not contain certain patches
if [ "$branch" == "master" ]; then
    oe_core_branch=upstream-master
else
    oe_core_branch=$(cat $wrlinux_dir/layers/wrlcompat/scripts/config/corebranch)
fi

echo "Using oe-core branch $oe_core_branch"

#clone oe-core if it does not exist
if [ ! -d $base/oe-core ]; then
    git clone --branch=$oe_core_branch $wrlinux_dir/git/oe-core $base/oe-core &> /dev/null
fi

cd $base/oe-core
git checkout $oe_core_branch &> /dev/null
git reset --hard origin/$oe_core_branch &> /dev/null

$base/oe-core/scripts/sstate-cache-management.sh --yes --remove-duplicated \
   --cache-dir=$base/nx/sstate_cache > $base/nx/sstate-cache-cleanup.log

