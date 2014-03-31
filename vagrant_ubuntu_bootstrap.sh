#!/bin/bash

echo "location=yow" > /tmp/location.txt
echo "hiera_datadir=/vagrant/hiera" > /tmp/hiera.txt
sudo mkdir -p /etc/facter/facts.d
sudo mv /tmp/location.txt /tmp/hiera.txt /etc/facter/facts.d
sudo hostname yow-vagrant
sudo apt-get install -y curl
sudo /vagrant/bootstrap.sh
echo "sudo puppet apply --modulepath=/vagrant/modules --hiera_config=/vagrant/hiera/hiera.yaml -e "
