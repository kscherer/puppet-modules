#!/usr/bin/env ruby
require 'rubygems'
require 'hiera'
require 'puppet'

# create a new instance based on config file
$hiera = Hiera.new(:config => "./hiera.yaml")

def lookup(family, os, release, arch)
  scope = { '::osfamily' => family, '::lsbmajdistrelease' => release,
    '::operatingsystem' => os, '::architecture' => arch,
    '::environment' => 'production',
    '::hiera_datadir' => '.'
  }
  $hiera.lookup("packages", nil, scope, nil, :array )
end

puts "#!/bin/sh"
puts
puts "#This script is generated. Do not edit this file."
puts "#Contact Konrad.Scherer@windriver.com for details."
puts
puts "#RedHat 5.x i386"
puts "RH5_i686='%s'" % lookup('RedHat', 'RedHat', '5', 'i386').join(' ')
puts
puts "#RedHat 5.x x86_64"
puts "RH5_x86_64='%s'" % lookup('RedHat', 'RedHat', '5', 'x86_64').join(' ')
puts
puts "#RedHat 6.x and Fedora 15 16 17 18 i386"
puts "RH6_i686='%s'" % lookup('RedHat', 'RedHat', '6', 'i386').join(' ')
puts
puts "#RedHat 6.x and Fedora 15 16 17 18 x86_64"
puts "RH6_x86_64='%s'" % lookup('RedHat', 'RedHat', '6', 'x86_64').join(' ')
puts
puts "#RedHat 7.x x86_64"
puts "RH7_x86_64='%s'" % lookup('RedHat', 'RedHat', '7', 'x86_64').join(' ')
puts
puts "#Fedora 19+ i386"
puts "F19_i686='%s'" % lookup('RedHat', 'Fedora', '19', 'i386').join(' ')
puts
puts "#Fedora 19+ x86_64"
puts "F19_x86_64='%s'" % lookup('RedHat', 'Fedora', '19', 'x86_64').join(' ')
puts
puts "#Ubuntu 10.04 i386"
puts "U1004_i686='%s'" % lookup('Debian', 'Ubuntu', '10.04', 'i386').join(' ')
puts
puts "#Ubuntu 10.04 x86_64"
puts "U1004_x86_64='%s'" % lookup('Debian', 'Ubuntu', '10.04', 'amd64').join(' ')
puts
puts "#Ubuntu 12.04 i386"
puts "U1204_i686='%s'" % lookup('Debian', 'Ubuntu', '12.04', 'i386').join(' ')
puts
puts "#Ubuntu 12.04 x86_64"
puts "U1204_x86_64='%s'" % lookup('Debian', 'Ubuntu', '12.04', 'amd64').join(' ')
puts
puts "#OpenSuSE 12.1 i386"
puts "OS121_i686='%s'" % lookup('Suse', 'OpenSuSE', '12', 'i386').join(' ')
puts
puts "#OpenSuSE 12.1 x86_64"
puts "OS121_x86_64='%s'" % lookup('Suse', 'OpenSuSE', '12', 'x86_64').join(' ')
puts
puts "#SLED 11 SP2 i386 (requires SLE 11 SP2 SDK)"
puts "SLED112_i686='%s'" % lookup('Suse', 'SLED', '11', 'i386').join(' ')
puts
puts "#SLED 11 SP2 x86_64 (requires SLE 11 SP2 SDK)"
puts "SLED112_x86_64='%s'" % lookup('Suse', 'SLED', '11', 'x86_64').join(' ')
puts
puts "#SLED 12 x86_64 (requires SLE 12 SDK)"
puts "SLED12_x86_64='%s'" % lookup('Suse', 'SLED', '12', 'x86_64').join(' ')
