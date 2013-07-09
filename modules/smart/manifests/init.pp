# == Class: smart
#
# Данный класс предоставляет конфигурацию демона S.M.A.R.T.
#
# This class provides S.M.A.R.T. daemon configuration
#
# === Parameters
# [*devices*]
#   list of monitored devices
# [*dev_type*]
#   (-d) Device type: ata, scsi, marvell, removable, 3ware,N, hpt,L/M/N
# [*prefailure*]
#   (-p) Report changes in 'Prefailure' Normalized Attributes
# [*default*]
#   (-a) Default: equivalent to -H -f -t -l error -l selftest -C 197 -U 198
# [*sheldule*]
#   (-s) Start self-test when type/date matches regular expression (see man smartd.conf)
# [*monitor_params*]
#   (-R) Track changes in Attribute ID Raw value with -p, -u or -t
# [*ignor_params*]
#   (-I) Ignore Attribute ID for -p, -u or -t Directive
# [*temperature*]
#   (-W) D,I,C Monitor Temperature D)ifference, I)nformal limit, C)ritical limit
# [*offline_test*]
#   (-o) Enable/disable automatic offline tests
# [*attr_autosave*]
#   (-S) Enable/disable attribute autosave
# [*email*]
#   (-m) Send warning email to ADD for -H, -l error, -l selftest, and -f
# [*email_type*]
#   (-M) Modify email warning behavior (see man smartd.conf)
# [*enabled*]
#   enable/disable daemon
# [*default_file*]
#   file from /etc/default
# [*default_string*]
#   string for default_file
# [*conf_file*]
#   full path to smartd.conf
# [*service*]
#   name of service
# [*package*]
#   name of package
#
# === Actions
# - install S.M.A.R.T. daemon package
# - configure and control daemon
#
# === Examples
#  class {'smart':
#    devices    => ['/dev/sda', '/dev/sdb',],
#    email      => 'mail@example.org',
#    email_type => 'diminishing',
#    sheldule   => '(S/../../(1|2|4|5|6)/01|L/../../(3|7)/01)',
#  }
#
# === Authors
# Anton Markelov <doublic@gmail.com> <markelovaa@dalstrazh.ru>
#
class smart(
  #smartd.conf
  $devices        = ['DEVICESCAN'],
  $dev_type       = false,                                       # -d
  $prefailure     = true,                                        # -p
  $default        = true,                                        # -a
  $sheldule       = '(S/../../(1|2|4|5|6)/01|L/../../(3|7)/01)', # -s
  $monitor_params = ['194'],                                     # -R
  $ignor_params   = false,                                       # -I
  $temperature    = false,                                       # -W
  $offline_test   = true,                                        # -o
  $attr_autosave  = true,                                        # -S
  $email          = 'root@mail.localnet',                        # -m
  $email_type     = 'diminishing',                               # -M
  #other
  $enabled        = true,
  $default_file   = '/etc/default/smartmontools',
  $default_string = 'start_smartd=',
  $conf_file      = '/etc/smartd.conf',
  $service        = 'UNSET',
  $package        = 'smartmontools'
) {

  #install
  package{$package:
    ensure => installed,
  }

  if $::osfamily == 'Debian' {
    #configure
    if $enabled{$yesno='yes'}
    else {$yesno='no'}

    file {$default_file:
      content => "${default_string}${yesno}",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
    Package[$package]->File[$default_file]->File[$conf_file]
  }

  file {$conf_file:
    content => template('smart/smartd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $service == 'UNSET' {
    case $::osfamily {
      'Debian': { $service_real = 'smartmontools' }
      default : { $service_real = 'smartd' }
    }
  }

  service {$service_real:
    ensure     => $enabled,
    enable     => $enabled,
    hasrestart => true,
    hasstatus  => true,
  }

  Package[$package]->File[$conf_file]~>Service[$service]
}


