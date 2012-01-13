
#
define nrpe_command ($command, $parameters='', $cplugdir='auto', $ensure='present') {

  # find out the default nagios paths for plugins
  if $::osfamily == 'RedHat' and $::architecture == 'x86_64' {
    $defaultdir = '/usr/lib64/nagios/plugins'
  } else {
    $defaultdir = '/usr/lib/nagios/plugins'
  }

  # if we overrode cplugdir then use that, else go with the nagios default
  # for this architecture
  case $cplugdir {
    auto:    { $plugdir = $defaultdir }
    default: { $plugdir = $cplugdir }
  }

  case $ensure {
    'absent': {
      file {
        "${nrpe::nrpe_dir}/${name}.cfg":
          ensure => absent
      }
    }
    default:    {
      file {
        "${nrpe::nrpe_dir}/${name}.cfg":
          owner   => root,
          group   => root,
          mode    => 644,
          content => template('nrpe/nrpe-config.erb'),
          require => File["$nrpe::nrpe_dir"],
      }
    }
  }
}

class nrpe {

  #this allows system to use both nrpe and mcollective
  $nrpe_dir = $::operatingsystem ? {
      /(?i-mx:centos|fedora|redhat|oel)/ => '/etc/nrpe.d',
      default                            => '/etc/nagios/nrpe.d',
  }

  file {
    ['/etc/nagios',"${nrpe_dir}"]:
      ensure => directory;
  }

  class debian {
    package {
      'nagios-plugins-basic':
        ensure => present;
    }
  }

  class redhat {

    include ::redhat

    package {
      [ 'nagios-plugins-disk', 'nagios-plugins-file_age', 'nagios-plugins-ntp',
        'nagios-plugins-procs']:
        ensure  => present,
        require => Yumrepo['epel'];
    }
  }

  class fedora {
    package {
      [ 'nagios-plugins-disk', 'nagios-plugins-file_age', 'nagios-plugins-ntp',
        'nagios-plugins-procs']:
        ensure => present;
    }
  }

  class opensuse {
    package {
      'nagios-plugins':
        ensure => present;
    }
  }

  case $::operatingsystem {
    Debian,Ubuntu: { include nrpe::debian }
    CentOS,RedHat: { include nrpe::redhat }
    Fedora:        { include nrpe::fedora }
    OpenSuSE,SLED: { include nrpe::opensuse }
    default:       { fail("Unknown distro") }
  }

  nrpe_command {
    'check_disks':
      command    => 'check_disk',
      parameters => '--warning=10% --critical=5% --path=/ --local --units GB';
    'check_ntp':
      command    => 'check_ntp_time',
      parameters => '-H 147.11.100.50 -w 0.5 -c 1';
    #make sure the nx log file has been updated recently. Checks if nx is hung
    'check_nx':
      command    => 'check_file_age',
      parameters => '-w 21600  -c 43200 -f /home/buildadmin/log/nx.log';
    #make sure puppet has successully run on system recently
    'check_puppet':
      command    => 'check_file_age',
      parameters => '-w 7200  -c 14400 -f /var/lib/puppet/state/state.yaml';
    #check whether there is an nx process running on the machine
    'check_nx_proc':
      command    => 'check_procs',
      parameters => '-c 1:4 -C nx';
  }
}
