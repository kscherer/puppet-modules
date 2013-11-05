#
class profile::bare_metal {
  include dell
  include dell::openmanage
  include dell::warranty

  @@nagios_service {
    "check_openmanage_${::hostname}":
      use                 => 'passive-service',
      service_description => 'Passive OpenManage',
      host_name           => $::fqdn,
      servicegroups       => 'dell-servers',
  }

  $nsca_server=hiera('nsca')
  $min=fqdn_rand(60)

  cron {
    'nsca_openmanage_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'Passive OpenManage' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_openmanage.sh -q",
      user    => 'nagios',
      minute  => $min;
  }

  if 'sda' in $::blockdevices {
    $model = $::blockdevice_sda_model
  } elsif 'sdc' in $::blockdevices {
    $model = $::blockdevice_sdc_model
  }

  if 'blade' in $::hostname {
    if 'PERC' in $model {
      $devices = {'/dev/sda'=>['megaraid,0', 'megaraid,1']}
    } elsif $::operatingsystem == 'Ubuntu' {
      $devices = ['/dev/sg3', '/dev/sg4',]
    } else {
      $devices = ['/dev/sg0', '/dev/sg1',]
    }
  } elsif 'yow-lpgbld-3' in $::hostname or 'ala-lpggp' in $::hostname or 'ala-git' in $::hostname {
    $devices = {'/dev/sda'=>[ 'megaraid,0', 'megaraid,1', 'megaraid,2',
                              'megaraid,3', 'megaraid,4', 'megaraid,5']}
  } elsif 'ala-lpd-' in $::hostname {
    $devices = {'/dev/sda'=>['sat+megaraid,0', 'sat+megaraid,1',
      'sat+megaraid,2', 'sat+megaraid,3', 'sat+megaraid,4', 'sat+megaraid,5']}
  } elsif 'yow-lpgbld-master' in $::hostname {
      $devices = {'/dev/sda'=>['megaraid,0', 'megaraid,1']}
  } elsif 'yow-cgts' in $::hostname {
    $devices = {'/dev/sda'=>['sat+megaraid,0', 'sat+megaraid,1',
      'sat+megaraid,2', 'sat+megaraid,3', 'sat+megaraid,4', 'sat+megaraid,5',
      'sat+megaraid,6','sat+megaraid,7']}
  }

  class {
    'smart':
      devices => $devices;
  }

  Class['wr::common::repos'] -> Class['smart']
}
