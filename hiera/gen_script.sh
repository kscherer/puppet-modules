#!/bin/sh

./gen_host_package_install.rb > host_package_install.sh
cat gen_host_package_install.sh >> host_package_install.sh
chmod +x host_package_install.sh
