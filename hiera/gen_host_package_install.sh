
arch=`uname -m`
kernel=`uname -r`
distro=""
install_check='rpm -q'
install_program=""

usage() {
	echo `basename $0`: Check and optionally install host packages for Wind River Linux 5.
	echo usage:
	echo -e "\t--help\t\tThis message"
	echo -e "\t--install\t\tInstall host packages detected as missing"
	echo -e "\t--dryrun\t\tOnly show command that would be used to install missing host packages"
	echo -e "\t--verbose\t\tIncrease output verbosity"
	echo -e "\t--yes\t\tPass --yes flag to package manager"
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
    if [ "$opt_verbose" == "1" ]; then
        echo "$1"
    fi
}

#check for redhat/fedora
if [ -e /usr/bin/yum ]; then
    install_program="yum $opt_yes install"
    #Look for RedHat 5 kernel
    if echo $kernel | grep -q '2.6.18'
    then
        distro=RH5
    else
        distro=RH6
    fi
elif [ -e /usr/bin/dpkg ]; then
    #we only support Ubuntu 12.04
    install_program="apt-get $opt_yes install"
    install_check='dpkg -L'
    distro=U1204
elif [ -e /usr/bin/zypper ]; then
    if [ -n "$opt_yes" ]; then
        opt_yes='-n'
    fi

    install_program="zypper $opt_yes install"
    if cat /etc/issue | grep -q '11\.4'
    then
        distro=OS114
    elif cat /etc/issue | grep -q 'SUSE Linux Enterprise'
    then
        distro=SLED112
    else
        distro=OS121
    fi
fi

host="${distro}_${arch}"
eval packages=\$$host
uninstalled=""

log "Checking for missing host packages using $install_check"

for package in $packages
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
    log "All required host packages are installed"
    exit 0
fi

install_command="sudo $install_program $uninstalled"

if [ "$opt_dryrun" == "1" ]; then
    echo "Dry run: Would execute $install_command"
    exit 0
fi

if [ "$opt_install" == "1" ]; then
    log $install_command
    $install_command
    exit $?
fi

echo "Following packages need to be installed: $uninstalled"
exit 1
