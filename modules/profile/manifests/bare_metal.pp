#
class profile::bare_metal {
  include dell
  include dell::openmanage
  include dell::warranty
  include snmp

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
      command => template('nagios/nsca_openmanage_check.erb'),
      user    => 'nagios',
      minute  => $min;
  }

  #on RH 5, the openmanage process is leaking semaphores
  #This command cleans them out once a week
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '5' {
    cron {
      'clear_nagios_semaphores':
        command => template('nagios/cron_clear_nagios_semaphores.erb'),
        user    => 'root',
        weekday => 0,
        hour    => 0,
        minute  => 0;
    }
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
