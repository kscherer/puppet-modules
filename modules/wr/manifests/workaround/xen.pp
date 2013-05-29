#
class wr::workaround::xen {
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
}
