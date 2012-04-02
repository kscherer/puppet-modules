#Class of workarounds specific to redhat class System
class redhat::workarounds {

  file_line {
    'stop_dhcp_modifying_ntp_conf':
      path => '/etc/sysconfig/network-scripts/ifcfg-eth0',
      line => 'PEERNTP=no';
    #perfer the arch of the package that matches the installation arch
    'multilib-policy-best':
      path => '/etc/yum.conf',
      line => 'multilib_policy=best';
  }

  #boolean variables from facter may be strings
  $is_virtual_bool = any2bool($::is_virtual)

  #A bug in some RedHat versions (I saw it on 6.0) causes lockups when
  #building wrlinux under Xen.
  #From https://bugzilla.redhat.com/show_bug.cgi?id=550724
  #this is the workaround.
  if ($is_virtual_bool == true and $::operatingsystem == 'RedHat' and
      $::operatingsystemrelease == '6.0') {
    service {
      'irqbalance':
        ensure => stopped,
        enable => false;
    }
  }

  if $::operatingsystemrelease < '5.2' {
    $yum_updatesd_hasstatus = false
  } else {
    $yum_updatesd_hasstatus = true
  }

  #make sure the firewall and other unnecessary services are disabled
  service {
    ['iptables','ip6tables','sendmail']:
      ensure => stopped,
      enable => false;
    'yum-updatesd':
      ensure    => stopped,
      enable    => false,
      hasstatus => $yum_updatesd_hasstatus;
  }

  if $::operatingsystem =~ /(RedHat|CentOS)/ {
    package {
      'redhat-lsb':
        ensure => installed,
    }
  }
}
