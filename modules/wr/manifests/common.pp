#
class wr::common {

  #Create standard base motd
  include motd

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
    'jch_laptop':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('jch@jch-schlepp.honig.net'),
      type   => 'ssh-rsa';
    'jch_server':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('jch@kismet.honig.net'),
      type   => 'ssh-rsa';
  }

  #central place to control puppet version. Created for 3.0 upgrade
  $puppet_version = 'present'

  #The puppet package get handled by puppet module, but not facter
  package {
    'facter':
      ensure   => 'latest';
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
  $puppet_server = hiera('puppet_server')

  $ala_ntp_servers = ['ntp-1.wrs.com','ntp-2.wrs.com','ntp-3.wrs.com']

  $ntp_servers = $::hostname ? {
    yow-lpggp2        => $ala_ntp_servers,
    pek-lpd-puppet    => $ala_ntp_servers,
    default           => hiera_array('ntp_servers')
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
