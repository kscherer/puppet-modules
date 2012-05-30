
#
define nrpe::command ($command, $parameters='', $cplugdir='auto', $ensure='present') {

  # if we overrode cplugdir then use that, else go with the nagios default
  # for this architecture
  case $cplugdir {
    auto:    { $plugdir = $nrpe::defaultdir }
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
          ensure  => 'present',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('nrpe/nrpe-config.erb'),
          require => File[$nrpe::nrpe_dir],
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

  # find out the default nagios paths for plugins
  if $::osfamily == 'RedHat' and $::architecture == 'x86_64' {
    $nagios_plugin_base = '/usr/lib64/nagios'
  } else {
    $nagios_plugin_base = '/usr/lib/nagios'
  }
  $defaultdir = "${nagios_plugin_base}/plugins"

  file {
    ['/etc/nagios', $nrpe_dir, $nagios_plugin_base, $defaultdir]:
      ensure => directory;
    'check_nx_instance':
      ensure => 'present',
      path   => "${defaultdir}/check_nx_instance.sh",
      source => 'puppet:///modules/nrpe/check_nx_instance.sh',
      mode   => '0755';
    'check_puppet':
      ensure => 'present',
      path   => "${defaultdir}/check_puppet.rb",
      source => 'puppet:///modules/nrpe/check_puppet.rb',
      mode   => '0755';
  }

  class debian {
    package {
      'nagios-plugins-basic':
        ensure => present;
    }
  }

  class redhat {
    package {
      [ 'nagios-plugins-disk', 'nagios-plugins-file_age', 'nagios-plugins-ntp',
        'nagios-plugins-procs']:
        ensure  => present,
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
    default:       { fail('Unknown distro') }
  }

  $first_ntp_server = $wr::common::ntp_servers[0]

  nrpe::command {
    'check_disks':
      command    => 'check_disk',
      parameters => '--warning=10% --critical=5% --all --ignore-eregi-path=\'(shm|boot|prebuilt_cache)\' --units GB';
    'check_ntp':
      command    => 'check_ntp_time',
      parameters => "-H $first_ntp_server -w 0.5 -c 1";
    #make sure the nx log file has been updated recently. Checks if nx is hung
    'check_nx':
      command    => 'check_file_age',
      parameters => '-w 21600  -c 43200 -f /home/buildadmin/log/nx.log';
    'check_nx_instance':
      command    => 'check_nx_instance.sh',
      parameters => '';
    #Check when the last time puppet was run
    'check_puppet':
      command    => 'check_puppet.rb',
      parameters => '--only-enabled --warn 7200 --critical 14400';
    #Uses the same script but checks if there have been any failures recently
    'check_puppet_failures':
      command    => 'check_puppet.rb',
      parameters => '--only-enabled --check-failures --warn 1 --critical 1';
    #check whether there is an nx process running on the machine
    'check_nx_proc':
      command    => 'check_procs',
      parameters => '-c 1:4 -C nx';
  }
}
