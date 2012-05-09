#
class wr::common {
  #Make sure that the machine is in the hosts file
  host {
    $::fqdn:
      ip           => $::ipaddress,
      host_aliases => $::hostname;
    'localhost':
      host_aliases => 'localhost.localdomain',
      ip           => '127.0.0.1';
  }

  ssh_authorized_key {
    'kscherer_windriver':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_home':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
    'cobbler_admin':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('bldadmin@yow-lpgbld-master'),
      type   => 'ssh-dss';
  }

  #The puppet package get handled by puppet module, but not facter
  case $::operatingsystem {
    /(OpenSuSE|SLED)/: {
      $facter_provider = 'gem'
      $facter_version = 'latest'
    }
    /(RedHat|Fedora|CentOS)/: {
      $facter_provider = 'yum'
      #newer versions of facter need dmidecode
      if $::operatingsystemrelease == '4' {
        $facter_version = '1.6.6'
      } else {
        $facter_version = 'latest'
      }
    }
    default: {
      $facter_provider = undef
      $facter_version = 'latest'
    }
  }

  package {
    'facter':
      ensure   => $facter_version,
      provider => $facter_provider;
  }

  #This path is used for stdlib facter_dot_d module
  file {
    '/etc/facter/':
      ensure => directory;
    '/etc/facter/facts.d/':
      ensure => directory;
    '/etc/facter/facts.d/location.txt':
      ensure  => present,
      content => inline_template( 'location=<%= hostname[0..2] %>' );
  }

  #boolean variables from facter may be strings
  $is_virtual_bool = any2bool($::is_virtual)

  #Another bug on some systems where is_virtual=false
  if $is_virtual_bool == false and $::hostname =~ /^yow-lpgbld-vm\d\d/ {
    file_line {
      'facter_xen_detect_workaround':
        path   => '/etc/fstab',
        line   => 'xenfs /proc/xen xenfs defaults 0 0',
        notify => Exec['remount_all'];
    }
    exec {
      'remount_all':
        command     => '/bin/mount -a',
        refreshonly => true
    }
  }

  #if vm is using older version of xen, give each vm its own independent clock.
  #in later versions of xen, this is the default so just assume each machine
  #will be running ntp
  if $is_virtual_bool == true {
    exec {
      'xen_independent_clock':
        command  => 'echo 1 > /proc/sys/xen/independent_wallclock',
        path     => '/usr/bin:/usr/sbin/:/bin',
        onlyif   => 'test `cat /proc/sys/xen/independent_wallclock` = \'0\'';
    }
  }

  #set the puppet server based on hostname
  $puppet_server = $::hostname ? {
    /^ala.*$/ => 'ala-lpd-puppet.wrs.com',
    /^pek.*$/ => 'pek-lpd-puppet.wrs.com',
    /^yow.*$/ => 'yow-lpd-puppet.wrs.com',
  }

  $ntp_servers = $::hostname ? {
    yow-lpgbld-master => ['ntp-1.wrs.com','ntp-2.wrs.com'],
    /^yow-lpgbld-.*/  => ['yow-lpgbld-master.wrs.com'],
    default           => ['ntp-1.wrs.com','ntp-2.wrs.com'],
  }

  #add my configs to all machines
  file {
    '/root/.bashrc':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/root/.aliases':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/root/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }

}
