#!/bin/bash

distribution=$(lsb_release --id --short)

if [ "$distribution" != "Ubuntu" ] && [ "$distribution" != "CentOS" ]; then
    echo "Currently only Ubuntu and CentOS are supported"
    exit 1
fi

if [ "$distribution" == "Ubuntu" ]; then
    release=$(lsb_release --codename --short)
elif [ "$distribution" == "CentOS" ]; then
    release=$(lsb_release --release --short | cut -d. -f1)
fi

echo "Bootstrap of $distribution $release"

location=""

facter_dir=/etc/facter/facts.d/
if [ -f ${facter_dir}/location.txt ]; then
    location=$(cat ${facter_dir}/location.txt | cut -d= -f2)
    echo "Using existing location $location"
else
    #try to figure out location by tracking external ip address
    #Currently only works for Ottawa and Alameda

    echo "Retrieving external ip address to determine location. May take a minute."
    external_ip=$(curl --silent http://ifconfig.me)
    #external_ip=$(dig +short @resolver1.opendns.com myip.opendns.com)

    #only look at first 2 parts of ip address
    classB_subnet=$(echo ${external_ip} | cut -d. -f1-2)
    if [ "x$classB_subnet" == "x128.224" ]; then
        location="yow"
    elif [ "x$classB_subnet" == "x147.11" ]; then
        location="ala"
    else
        echo "Unable to determine location"
        exit 1
    fi
    echo "Using location $location"

    mkdir -p $facter_dir
    echo "location=$location" > /tmp/location.txt
    mv /tmp/location.txt $facter_dir/location.txt
fi

#Make sure bootstrap uses valid mirror
if [ "x$location" != "xala" ] && [ "x$location" != "xyow" ]; then
    echo "Bootstrap currently only supports Ottawa and Alameda mirrors, defaulting to Alameda"
    location="ala"
fi

if [ "$distribution" == "Ubuntu" ]; then
    #setup local apt repos to make sure installation of puppet is successful
    echo "# Repos managed by puppet." > /etc/apt/sources.list

    sources_dir=/etc/apt/sources.list.d
    rm -f $sources_dir/*.list

    cat > $sources_dir/${location}-mirror_ubuntu.list <<EOF
# ${location}-mirror_ubuntu
deb http://${location}-mirror.wrs.com/mirror/ubuntu.com/ubuntu ${release} main restricted universe
EOF

    cat > $sources_dir/${location}-mirror_ubuntu_security.list <<EOF
# ${location}-mirror_ubuntu_security
deb http://${location}-mirror.wrs.com/mirror/ubuntu.com/ubuntu ${release}-security main restricted universe
EOF

    cat > $sources_dir/${location}-mirror_ubuntu_updates.list <<EOF
# ${location}-mirror_ubuntu_updates
deb http://${location}-mirror.wrs.com/mirror/ubuntu.com/ubuntu ${release}-updates main restricted universe
EOF

    cat > $sources_dir/${location}_puppetlabs_mirror.list <<EOF
# ${location}_puppetlabs_mirror
deb http://${location}-mirror.wrs.com/mirror/puppetlabs/apt ${release} main dependencies
EOF

    curl --silent --output /tmp/puppetlabs-release-$release.deb \
        http://${location}-mirror.wrs.com/mirror/puppetlabs/apt/puppetlabs-release-${release}.deb
    dpkg --install /tmp/puppetlabs-release-${release}.deb

    #puppetlabs release package installs sources file
    rm -f $sources_dir/puppetlabs.list

    apt-get -qq update
    apt-get -y install puppet facter hiera
elif [ "$distribution" == "CentOS" ]; then

    #delete the default centos repos
    rm -f /etc/yum.repos.d/*.repo

    #setup yum repos same as puppet class to avoid agent failure
    #while updating repos
    cat > /etc/yum.repos.d/centos-os.repo <<END
[centos-os]
name=centos-os
baseurl=http://${location}-mirror.wrs.com/mirror/centos/${release}/os/x86_64
enabled=1
gpgcheck=1
gpgkey=http://${location}-mirror.wrs.com/mirror/centos/${release}/os/x86_64/RPM-GPG-KEY-CentOS-${release}
END

    cat > /etc/yum.repos.d/centos-updates.repo <<END
[centos-updates]
name=centos-updates
baseurl=http://${location}-mirror.wrs.com/mirror/centos/${release}/updates/x86_64
enabled=1
gpgcheck=1
gpgkey=http://${location}-mirror.wrs.com/mirror/centos/${release}/os/x86_64/RPM-GPG-KEY-CentOS-${release}
END

    cat > /etc/yum.repos.d/epel.repo <<END
[epel]
name=epel
baseurl=http://${location}-mirror.wrs.com/mirror/epel/${release}/x86_64
enabled=1
gpgcheck=1
gpgkey=http://${location}-mirror.wrs.com/mirror/epel/RPM-GPG-KEY-EPEL-${release}
END

    cat > /etc/yum.repos.d/puppetlabs.repo <<END
[puppetlabs]
name=puppetlabs
baseurl=http://${location}-mirror.wrs.com/mirror/puppetlabs/yum/el/${release}/products/x86_64
enabled=1
gpgcheck=1
gpgkey=http://${location}-mirror.wrs.com/mirror/puppetlabs/yum/RPM-GPG-KEY-puppetlabs
END

    cat > /etc/yum.repos.d/puppetlabs-deps.repo <<END
[puppetlabs-deps]
name=puppetlabs-deps
baseurl=http://${location}-mirror.wrs.com/mirror/puppetlabs/yum/el/${release}/dependencies/x86_64
enabled=1
gpgcheck=1
gpgkey=http://${location}-mirror.wrs.com/mirror/puppetlabs/yum/RPM-GPG-KEY-puppetlabs
END

    yum clean all
    yum -y install puppet facter hiera
fi
