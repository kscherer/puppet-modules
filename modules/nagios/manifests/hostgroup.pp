#Puppetize standard nagios definitions
class nagios::hostgroup(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

    @@nagios_hostgroup {
      'hostel':
        hostgroup_name => 'hostel',
        alias          => 'Host Test Lab';
      'yow-blades':
        hostgroup_name => 'yow-blades',
        alias          => 'YOW blades';
      'yow-lpggp':
        hostgroup_name => 'yow-lpggp',
        alias          => 'YOW support';
      'ala-blades':
        hostgroup_name => 'ala-blades',
        alias          => 'ALA blades';
    }

    #make sure that entries no longer in storedconfigs are cleaned out
    resources {
      'nagios_hostgroup':
        notify => Host['nagios'],
        purge  => true;
    }

    $hostgroup_cfg = "${nagios_dir}/nagios_hostgroup.cfg"
    Nagios_hostgroup <<||>> {
      notify  => Host['nagios'],
      require => File[$nagios_dir],
      before  => File[$hostgroup_cfg],
    }

    file {
      $hostgroup_cfg:
        notify  => Host['nagios'],
        require => Package['nagios'],
        owner   => 'root',
        group   => 'nagios',
        mode    => '0664',
    }
  }
