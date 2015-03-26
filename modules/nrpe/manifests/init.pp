
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
        ["${nrpe::nrpe_dir}/${name}.cfg","/etc/nagios/${name}.sh"]:
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
          require => File[$nrpe::nrpe_dir];
        "/etc/nagios/${name}.sh":
          ensure  => 'present',
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => template('nrpe/nrpe-script.erb');
      }
    }
  }
}

# Class to install nagios nrpe scripts. These scripts are used by mcollective
# and are not used with nrpe daemon
class nrpe {

  #this allows system to use both nrpe and mcollective
  $nrpe_dir = $::osfamily ? {
      'RedHat' => '/etc/nrpe.d',
      default  => '/etc/nagios/nrpe.d',
  }

  # find out the default nagios paths for plugins
  if $::osfamily == 'RedHat' and $::architecture == 'x86_64' {
    $nagios_plugin_base = '/usr/lib64/nagios'
  } else {
    $nagios_plugin_base = '/usr/lib/nagios'
  }
  $defaultdir = "${nagios_plugin_base}/plugins"

  File {
    owner => 'root',
    group => 'root',
  }

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
    #This is the perl script that checks log files for specific strings
    'check_logfiles':
      ensure => 'present',
      path   => "${defaultdir}/check_logfiles",
      source => 'puppet:///modules/nrpe/check_logfiles',
      mode   => '0755';
    #This is the config file for using check_logfiles on grokmirror logs
    "${nrpe::nrpe_dir}/grokmirror.cfg":
      ensure => 'present',
      source => 'puppet:///modules/nrpe/grokmirror.cfg',
      mode   => '0644';
    # Script to check for disks that have gone read only
    'check_ro_mounts':
      ensure => 'present',
      path   => "${defaultdir}/check_ro_mounts",
      source => 'puppet:///modules/nrpe/check_ro_mounts',
      mode   => '0755';
    # Script to check zookeeper cluster health
    'check_zookeeper':
      ensure => 'present',
      path   => "${defaultdir}/check_zookeeper.py",
      source => 'puppet:///modules/nrpe/check_zookeeper.py',
      mode   => '0755';
  }

  # Special binary and script to monitor disks on C6220
  if $::boardproductname == '09N44V' {
    file {
      # binary from LSI for basic reporting on disks and RAID health
      # downloaded from http://www.lsi.com/downloads/Public/Host%20Bus%20Adapters/Host%20Bus%20Adapters%20Common%20Files/SAS_SATA_6G_P20/SAS2IRCU_P20.zip
      # More info here: http://hwraid.le-vert.net/wiki/LSIFusionMPTSAS2
      '/usr/bin/sas2ircu':
        ensure => 'present',
        source => 'puppet:///modules/nrpe/sas2ircu',
        owner  => 'root',
        group  => 'root',
        mode   => '0755';
      # wrapper script for sas2ircu downloaded from hwraid project
      # https://raw.githubusercontent.com/eLvErDe/hwraid/master/wrapper-scripts/sas2ircu-status
      'check_lsi_sas_disks':
        ensure => 'present',
        path   => "${defaultdir}/sas2ircu-status",
        source => 'puppet:///modules/nrpe/sas2ircu-status',
        mode   => '0755';
    }
  }

  case $::operatingsystem {
    'Debian','Ubuntu': {
      $nagios_packages = 'nagios-plugins-basic'
      file {
        'check_openmanage':
          ensure  => present,
          source  => 'puppet:///modules/nrpe/check_openmanage',
          path    => "${defaultdir}/check_openmanage",
          mode    => '0755',
          require => Package['nagios-plugins-basic'];
      }
    }
    'CentOS','RedHat','Fedora': {
      $nagios_packages = ['nagios-plugins-disk', 'nagios-plugins-file_age',
                          'nagios-plugins-ntp', 'nagios-plugins-procs',
                          'nagios-plugins-openmanage']
    }
    'OpenSuSE': {
      if $::operatingsystem == 'OpenSuSE' and $::operatingsystemrelease == '13.2' {
        $nagios_packages = ['monitoring-plugins-disk', 'monitoring-plugins-file_age',
                            'monitoring-plugins-ntp_time', 'monitoring-plugins-procs']
      } else {
        $nagios_packages = 'nagios-plugins'
      }
    }
    'SLED': {
      $nagios_packages = ['nagios-plugins-disk', 'nagios-plugins-file_age',
                          'nagios-plugins-ntp_time', 'nagios-plugins-procs']
    }
    default:       { fail('Unknown distro') }
  }

  package {
    $nagios_packages:
      ensure => latest;
  }

  $ntp_servers = hiera('ntp::servers')
  $first_ntp_server = $ntp_servers[0]

  $base_om_flags = '--state --extinfo --timeout=60'
  # special cases for different hardware
  case $::boardproductname {
    '0599V5': { # R730xd: ignore system battery unknown
      $om_flags = "${base_om_flags} --vdisk-critical --blacklist bp=all"
    }
    '09N44V': { # C6220II: OM does not support storage, ignore PSU unknown
      $om_flags = "${base_om_flags} --no-storage --blacklist ps=all"
    }
    default:  { # ignore battery charging warning and old controller firmware warning
      $om_flags = "${base_om_flags} --vdisk-critical --blacklist bat_charge=all --blacklist ctrl_driver=all"
    }
  }

  nrpe::command {
    'check_disks':
      command    => 'check_disk',
      parameters => '--warning=10% --critical=5% --all --ignore-eregi-path=\'(shm|boot|prebuilt_cache|folk|net|india|stored_builds)\' --units GB';
    'check_ntp':
      command    => 'check_ntp_time',
      parameters => "-H ${first_ntp_server} -w 1.0 -c 2.0";
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
    #Check the status of the hardware using dell openmanage
    'check_openmanage':
      command    => 'check_openmanage',
      parameters => $om_flags;
    'check_grokmirror_log':
      command    => 'check_file_age',
      parameters => '-w 300  -c 600 -f /git/log/ala-git.wrs.com.log';
    'check_grokmirror_log_errors':
      command    => 'check_logfiles',
      parameters => "--config ${nrpe::nrpe_dir}/grokmirror.cfg";
    'check_external_log_errors':
      command    => 'check_logfiles',
      parameters => '--logfile=/home/git/sync/external.log --criticalpattern=error';
    'check_wrlinux_update':
      command    => 'check_logfiles',
      parameters => '--logfile=/home/wrlbuild/log/wrlinux_update.log --rotation=loglog1gzlog2gz --criticalpattern="pull failed on subgit" --criticalpattern="Error:"';
    'check_lsi_disks':
      command    => 'sas2ircu-status',
      parameters => '--nagios';
    'check_ro_mounts':
      command    => 'check_ro_mounts',
      parameters => '-X nfs -X proc -X cgroup -X fuse -X tmpfs -X iso9660 -x "/mnt/*"';
  }
}
