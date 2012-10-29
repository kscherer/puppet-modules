#!/bin/sh

#RedHat 5.x i386 (uses prebuilt Python 2.7.3 and chrpath layer)
RH5_i686='texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath'

#RedHat 5.x x86_64 (uses prebuilt Python 2.7.3 and chrpath layer)
RH5_x86_64='glibc.i686 glibc-devel.i386 libgcc.i386 texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath'

#RedHat 6.x and Fedora 15 16 17 i386
RH6_i686='texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath'

#RedHat 6.x and Fedora 15 16 17 x86_64
RH6_x86_64='glibc.i686 glibc-devel.i686 libgcc.i686 texi2html diffstat subversion mesa-libGL mesa-libGLU SDL-devel texinfo gawk gcc gcc-c++ help2man chrpath'

#Ubuntu 12.04 i386
U1204_i686='texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++'

#Ubuntu 12.04 x86_64
U1204_x86_64='texi2html chrpath diffstat subversion libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texinfo gawk gcc help2man g++'

#OpenSuSE 11.4 i386
OS114_i686='chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0'

#OpenSuSE 11.4 x86_64
OS114_x86_64='gcc-32bit chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0'

#OpenSuSE 12.1 i386
OS121_i686='chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0'

#OpenSuSE 12.1 x86_64
OS121_x86_64='gcc-32bit chrpath diffstat subversion Mesa Mesa-devel make libSDL-devel texinfo gawk gcc gcc-c++ help2man patch python-curses libsqlite3-0'

#SLED 11 SP2 i386 (requires SLE 11 SP2 SDK)
SLED112_i686='make texinfo gawk gcc gcc-c++ patch diffstat subversion chrpath Mesa-devel SDL-devel python-curses'

#SLED 11 SP2 x86_64 (requires SLE 11 SP2 SDK)
SLED112_x86_64='gcc43-32bit make texinfo gawk gcc gcc-c++ patch diffstat subversion chrpath Mesa-devel SDL-devel python-curses'

arch=`uname -m`
kernel=`uname -r`
distro=""
install_check='rpm -q'
install_program=""

#check for redhat/fedora
if [ -e /usr/bin/yum ]; then
    install_program="yum install"
    #Look for RedHat 5 kernel
    if echo $kernel | grep -q '2.6.18'
    then
        distro=RH5
    else
        distro=RH6
    fi
elif [ -e /usr/bin/dpkg ]; then
    #we only support Ubuntu 12.04
    install_program="apt-get install"
    install_check='dpkg -l'
    distro=U1204
elif [ -e /usr/bin/zypper ]; then
    install_program="zypper install"
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

echo "Checking for missing host packages"

for package in $packages
do
    if $install_check $package 2>&1 > /dev/null
    then
        echo "Package $package already installed"
    else
        echo "Package $package not installed"
        uninstalled="$package $uninstalled"
    fi
done

if [ -n "$uninstalled" ]; then
    echo "Following packages need to be installed: $uninstalled"
    install_command="sudo $install_program $uninstalled"
    echo $install_command
    $install_command
fi
