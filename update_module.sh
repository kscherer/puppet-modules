#!/bin/bash

module=$1

if [ -z "$module" ]; then
    echo "Usage: update_module <module> "
    exit 1
fi

#Check that branch matching module name exists
git branch | grep -q $module &> /dev/null
if [ "$?" == "1" ]; then
    echo "Branch $module not found"
    exit 1
fi
set -x

#update local branch
git checkout $module
git pull

#back to production
git checkout production

#merge changes into production
git merge --squash -s subtree $module

#Stop before commit
