#!/bin/bash

set -x

function update_module {
    local module=$1

    #update local branch
    git checkout $module
    git pull

    #back to production
    git checkout production
}

function merge_module() {
    local module=$1

    #merge changes into production
    git merge -s -no-edit subtree -Xtheirs $module
}

modules="openstack cinder glance horizon keystone nova quantum rabbitmq swift vswitch"

for module in $modules; do
    update_module $module
done

for module in $modules; do
    merge_module $module
done

#Stop before commit
