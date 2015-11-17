#
class profile::bare_metal {
  include dell
  include dell::openmanage
  include snmp
  include ::profile::consul

  Class['wr::common::repos'] -> Class['dell::openmanage']
  Class['wr::common::repos'] -> Class['snmp']

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

  # Special binary and script to monitor disks on C6220
  if $::boardproductname == '09N44V' {
    $lsi_service_desc = 'Passive LSI Disk Check'
    @@nagios_service {
      "check_lsi_disks_${::hostname}":
        use                 => 'passive-service',
        service_description => $lsi_service_desc,
        host_name           => $::fqdn,
        servicegroups       => 'dell-servers',
    }

    cron {
      'nsca_lsi_disk_check':
        command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S \'${lsi_service_desc}\' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_lsi_disks.sh -q",
        user    => 'nagios',
        minute  => $min;
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
    } elsif 'Logical Volume' == $model and 'LSI' == $::blockdevice_sda_vendor {
      $devices = ['/dev/sg1', '/dev/sg2', '/dev/sg3']
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
  } elsif 'lpdfs01' in $::hostname {
    $devices = {'/dev/sda'=>[ 'megaraid,0', 'megaraid,1', 'megaraid,2',
                              'megaraid,3', 'megaraid,4', 'megaraid,5',
                              'megaraid,6', 'megaraid,7', 'megaraid,8',
                              'megaraid,9', 'megaraid,10', 'megaraid,11',
                              'megaraid,12', 'megaraid,13']}
  }

  class {
    'smart':
      devices => $devices;
  }

  Class['wr::common::repos'] -> Class['smart']
}
