#!/bin/bash

distribution=$(lsb_release --id --short)

if [ "$distribution" != "Ubuntu" ]; then
    echo "Currently only Ubuntu is supported"
    exit 1
fi

release=$(lsb_release --codename --short)
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
if [ "x$location" != "xala" ] || [ "x$location" != "xyow" ]; then
    echo "Bootstrap currently only supports Ottawa and Alameda mirrors, defaulting to Alameda"
    location="ala"
fi

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
