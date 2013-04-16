#!/bin/bash

module=$1
repo=$2

if [ -z "$module" ] || [ -z "$repo" ]; then
    echo "Usage: add_module <module> <repo>"
    exit 1
fi

#make sure module does not already exist
git remote show $module &> /dev/null
if [ "$?" == "0" ]; then
    echo "Puppet module $module already exists."
    exit 1
fi

#make sure directory doesn't already exist
if [ -d "modules/$module" ]; then
    echo "Directory modules/$module already exists."
    exit 1
fi

set -x

#add remote and fetch repos
git remote add -f $module $repo

#make local branch which is same as remote repo
git checkout -b $module ${module}/master

#Move back to production branch
git checkout production

#Group commits from upstream repo into merge commit
git merge -s ours --no-commit $module

#Mount tree into production branch
git read-tree --prefix=modules/$module -u $module

#stop before commit

