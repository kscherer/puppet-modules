
arch=`uname -m`
distro=""
install_check='rpm -q'
install_program=""

usage() {
	echo `basename $0`: Check and optionally install host packages for Wind River Linux 5.
	echo usage:
	echo "--help - This message"
	echo "--install - Install host packages detected as missing"
	echo "--dryrun - Only show command that would be used to install missing host packages"
	echo "--verbose - Increase output verbosity"
	echo "--yes - Pass --yes flag to package manager"
	exit 1
}

opt_install=0
opt_dryrun=0
opt_verbose=0
opt_yes=

for arg
do
    case $arg in
    --)    shift; break ;;
    --install)
        opt_install=1
        ;;
     --dryrun)
        opt_dryrun=1
        ;;
     --verbose)
        opt_verbose=1
        ;;
     --yes)
        opt_yes='-y'
        ;;
    *)
        usage
        ;;
    esac
done

log() {
    if [ x"$opt_verbose" = x1 ]; then
        echo "$1"
    fi
}

#check for redhat/fedora
if [ -e /usr/bin/yum ]; then
    install_program="yum $opt_yes install"

    #detect Fedora
    if [ -f /etc/fedora-release ]; then
        #Retrieve fedora release
        fedora_release=$(cut -d\  -f 3 < /etc/fedora-release)
        if [ "$fedora_release" -ge '19' ]; then
            distro=F19
        else
            distro=RH6
        fi
    #Detects 5.x release on RedHat, CentOS, Oracle, etc.
    elif cat /etc/*-release | grep 'release 5\.' > /dev/null 2>&1
    then
        distro=RH5
    elif cat /etc/*-release | grep 'release 6\.' > /dev/null 2>&1
    then
        distro=RH6
    else
        distro=RH7
    fi
elif [ -e /usr/bin/dpkg ]; then
    #wrlinux only supports Ubuntu LTS releases, but the
    #12.04 package list works for Debian squeeze/wheezy
    install_program="apt-get $opt_yes install"
    install_check='dpkg -L'
    if grep DISTRIB_RELEASE /etc/lsb-release | grep -q 10.04
    then
        distro=U1004
    else
        distro=U1204
    fi
elif [ -e /usr/bin/zypper ]; then
    if [ -n "$opt_yes" ]; then
        opt_yes='-n'
    fi

    install_program="zypper $opt_yes install"
    if grep -q '11\.4' /etc/issue
    then
        distro=OS114
    elif grep -q 'SUSE Linux Enterprise' /etc/issue
    then
        distro=SLED112
    else
        distro=OS121
    fi
fi

#Exit if distro cannot be determined
if [ -z $distro ]; then
    echo "Could not determine distro and required packages."
    exit 1
fi

host="${distro}_${arch}"
eval packages=\$$host
uninstalled=""

log "Looking for additional host packages in addons"
all_addon_packages=
for addon_package_file in $(dirname $0)/../addons/*/addon_host_packages.txt; do
    addon_packages=`grep $distro $addon_package_file 2> /dev/null | cut -d= -f2`
    if [ -n "$addon_packages" ]; then
        all_addon_packages="$addon_packages $all_addon_packages"
    fi
done

log "Checking for missing host packages using $install_check"
for package in $packages $all_addon_packages
do
    if $install_check $package > /dev/null 2>&1
    then
        log "Package $package already installed"
    else
        log "Package $package not installed"
        uninstalled="$package $uninstalled"
    fi
done

if [ -z "$uninstalled" ]; then
    echo "All required host packages are installed"
    exit 0
fi

install_command="sudo $install_program $uninstalled"

if [ x"$opt_dryrun" = x1 ]; then
    echo "Dry run: Would execute $install_command"
    exit 0
fi

if [ x"$opt_install" = x1 ]; then
    log $install_command
    $install_command
    exit $?
fi

echo "Following packages need to be installed: $uninstalled"
exit 1
