#!/bin/bash

module=$1

set -x

#update local branch
git checkout $module
git pull

#back to production
git checkout production

#merge changes into production
git merge --squash -s subtree $module

#Stop before commit
