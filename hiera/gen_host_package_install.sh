
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
