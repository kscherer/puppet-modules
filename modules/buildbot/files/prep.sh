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

#clean up any previous wrlinux repo
if [ ! -d wrlinux-x ]; then
    rm -rf wrlinux-x
fi

# Reference clone wrlinux
$HOME/bin/wrgit clone --reference $HOME/wrlinux-x --branch $opt_branch $opt_repo

#clean out any previous builds
if [ -d $opt_buildername ]; then
    rm -rf $opt_buildername
fi

#Update builder with latest commits
#make sure branch is correct
cd wrlinux-x
$HOME/bin/wrgit checkout $opt_branch
$HOME/bin/wrgit pull
