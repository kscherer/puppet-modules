#!/bin/bash

opt_release=
opt_branch=
opt_repo=
opt_buildername=

for arg
do
    case $arg in
        --) shift; break ;;
        --release=*)
        opt_release=${arg#--release=}
        ;;
        --branch=*)
        opt_branch=${arg#--branch=}
        ;;
        --repo=*)
        opt_repo=${arg#--repo=}
        ;;
        --buildername=*)
        opt_buildername=${arg#--buildername=}
        ;;
        *)
            echo >&2 "warning: Unrecognized option '$arg'"
            exit 1
            ;;
    esac
done

set -x

#make sure initial clone is created
if [ ! -d $HOME/wrlinux-x ]; then
    pushd $HOME
    $HOME/bin/wrgit clone $opt_repo
    popd
fi

# Reference clone wrlinux if it does not exist
if [ ! -d wrlinux-x ]; then
    $HOME/bin/wrgit clone --reference $HOME/wrlinux-x --branch $opt_branch $opt_repo
fi

#clean out any previous builds
if [ -d $opt_buildername ]; then
    rm -rf $opt_buildername
fi

#Update builder with latest commits
#make sure branch is correct
cd wrlinux-x
wrgit checkout $opt_branch
wrgit pull
