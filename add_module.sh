#!/bin/bash

module=$1
repo=$2

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

