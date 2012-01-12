#Class of workarounds specific to redhat class System
class redhat::workarounds {
  
  file_line {
    "stop_dhcp_modifying_ntp_conf":
      path => "/etc/sysconfig/network-scripts/ifcfg-eth0",
      line => "PEERNTP=no";
    #perfer the arch of the package that matches the installation arch
    'multilib-policy-best':
      path => '/etc/yum.conf',
      line => 'multilib_policy=best';
  }

  #A bug in some RedHat versions (I saw it on 6.0) causes lockups when
  #building wrlinux under Xen. From https://bugzilla.redhat.com/show_bug.cgi?id=550724
  #this is the workaround.
  if $::is_virtual == 'true' and $::operatingsystem == 'RedHat' and $::operatingsystemrelease == '6.0' {
    service {
      'irqbalance':
        enable => false,
        ensure => stopped;
    }
  }

  #Another bug on Fedora systems where facter 1.6.2 reports is_virtual=false
  if $::is_virtual == 'true' and $::operatingsystem == 'Fedora' and $::facterversion == '1.6.2' {
    file_line {
      "facter_xen_detect_workaround":
        path => '/etc/fstab',
        line => 'xenfs /proc/xen xenfs defaults 0 0',
        notify => Exec['remount_all'];
    }
    exec {
      'remount_all':
        command => '/bin/mount -a',
        refreshonly => true
    }
  }
}
