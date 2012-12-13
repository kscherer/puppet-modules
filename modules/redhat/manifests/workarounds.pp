#Class of workarounds specific to redhat class System
class redhat::workarounds {

  file_line {
    # 'stop_dhcp_modifying_ntp_conf':
    #   path => '/etc/sysconfig/network-scripts/ifcfg-eth0',
    #   line => 'PEERNTP=no';
    #prefer the arch of the package that matches the installation arch
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

  if $::operatingsystem == 'Fedora' {
    $iptables_hasstatus = false
  } else {
    $iptables_hasstatus = true
  }

  #make sure the firewall and other unnecessary services are disabled
  service {
    ['iptables','ip6tables']:
      ensure    => stopped,
      hasstatus => $iptables_hasstatus,
      enable    => false;
    'yum-updatesd':
      ensure    => stopped,
      enable    => false,
      hasstatus => $yum_updatesd_hasstatus;
  }

  #Need lsb package for facter lsb variables
  ensure_resource('package', 'redhat-lsb', {'ensure' => 'installed' })

  #cron is absolutely necessary
  if ($::osfamily == 'RedHat' and $::lsbmajdistrelease == '6') {
    ensure_resource('package', 'cronie', {'ensure' => 'installed' })

    #by default ssmtp is installed but times out with long cron scripts
    #so use postfix but it requires configuration
    ensure_resource('package', 'postfix', {'ensure' => 'installed' })
    file_line {
      'set_smtp_server':
        path   => '/etc/mail.rc',
        line   => 'set smtp="prod-webmail.wrs.com"';
    }

    #Just use postfix as sendmail replacement, not full smtp service
    service {
      'postfix':
        ensure => stopped,
        enable => false;
    }

    #failed attempt to use exim, will remove later
    ensure_resource('package', 'exim', {'ensure' => 'absent' })
    ensure_resource('package', 'ssmtp', {'ensure' => 'absent' })
  }

  #Puppet 3.0 requires ruby 1.8.7 so puppetlabs made custom EL5 ruby rpm
  if ($::osfamily == 'RedHat' and $::lsbmajdistrelease == '5') {
    ensure_resource('package', 'ruby', {'ensure' => 'latest' })
  }
}
