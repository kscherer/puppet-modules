#!/bin/sh

#RedHat 5.x i386 (uses prebuilt Python 2.7.3 and chrpath layer)
RH5_i686='texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath git pygtk2 bzip2 wget tar patch screen'

#RedHat 5.x x86_64 (uses prebuilt Python 2.7.3 and chrpath layer)
RH5_x86_64='glibc.i686 glibc-devel.i386 glibc-devel.x86_64 libgcc.i386 ncurses.i386 texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath git pygtk2 bzip2 wget tar patch screen'

#RedHat 6.x and Fedora 15 16 17 18 i386
RH6_i686='texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath git pygtk2 bzip2 wget tar patch screen'

#RedHat 6.x and Fedora 15 16 17 18 x86_64
RH6_x86_64='glibc.i686 glibc-devel.i686 glibc-devel.x86_64 libgcc.i686 ncurses-libs.i686 texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath git pygtk2 bzip2 wget tar patch screen'

#Ubuntu 10.04 i386
U1004_i686='texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++ git-core python-gtk2 bash screen'

#Ubuntu 10.04 x86_64
U1004_x86_64='libc6-i386 libc6-dev-i386 lib32ncurses5 texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++ git-core python-gtk2 bash screen'

#Ubuntu 12.04 i386
U1204_i686='texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++ git-core python-gtk2 bash screen'

#Ubuntu 12.04 x86_64
U1204_x86_64='libc6:i386 libc6-dev-i386 libncurses5:i386 texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++ git-core python-gtk2 bash screen'

#OpenSuSE 11.4 i386
OS114_i686='chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0 git python-gtk screen'

#OpenSuSE 11.4 x86_64
OS114_x86_64='gcc-32bit libncurses5-32bit chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0 git python-gtk screen'

#OpenSuSE 12.1 i386
OS121_i686='chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0 git python-gtk screen'

#OpenSuSE 12.1 x86_64
OS121_x86_64='gcc-32bit libncurses5-32bit chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0 git python-gtk screen'

#SLED 11 SP2 i386 (requires SLE 11 SP2 SDK)
SLED112_i686='make texinfo gawk gcc gcc-c++ patch diffstat subversion chrpath Mesa-devel SDL-devel python-curses git python-gtk screen'

#SLED 11 SP2 x86_64 (requires SLE 11 SP2 SDK)
SLED112_x86_64='gcc43-32bit libncurses5-32bit make texinfo gawk gcc gcc-c++ patch diffstat subversion chrpath Mesa-devel SDL-devel python-curses git python-gtk screen'

arch=`uname -m`
kernel=`uname -r`
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
    if echo $kernel | grep -q '^2.6'
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
