# Class: puppet::agent
#
# This class installs and configures the puppet agent
#
# Parameters:
# [*puppet_defaults*]             - Path to puppet service defaults file
# [*puppet_agent_service*]        - Name of the puppet agent service
# [*puppet_agent_name*]           - Name of the puppet agent package
# [*puppet_conf*]                 - Path to the puppet config file
# [*puppet_server*]               - FQDN of the puppet server
# [*package_provider*]            - Provider of the puppet package
# [*puppet_agent_ensure*]         - Version number of state of puppet package
# [*puppet_agent_service_enable*] - Whether to enable puppet service
#
# Actions:
#
# Requires:
#
#  Class['concat']
#  Class['stdlib']
#  Class['concat::setup']
#
# Sample Usage:
#  class { "puppet::agent":
#    puppet_agent_service        => 'puppet',
#    puppet_agent_name           => 'puppet',
#    puppet_conf                 => '/etc/puppet/puppet.conf',
#    puppet_server               => 'puppet.mydomain.com',
#    puppet_agent_service_enable => false,
#  }
#
class puppet::agent(
  $puppet_defaults             = $puppet::params::puppet_defaults,
  $puppet_agent_service        = $puppet::params::puppet_agent_service,
  $puppet_agent_name           = $puppet::params::puppet_agent_name,
  $puppet_conf                 = $puppet::params::puppet_conf,
  $puppet_server               = $puppet::params::puppet_server,
  $package_provider            = $puppet::params::package_provider,
  $puppet_agent_ensure         = present,
  $puppet_agent_service_enable = true
) inherits puppet::params {

  if $kernel == "Linux" {
    file { $puppet_defaults:
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => "puppet:///modules/puppet/${puppet_defaults}",
    }
  }

  #install or remove the puppet agent package
  if ! defined(Package[$puppet_agent_name]) {
    package { $puppet_agent_name:
      ensure   => $puppet_agent_ensure,
      provider => $package_provider,
    }
  }

  if $puppet_agent_service_enable == true and $puppet_agent_ensure == 'present' {

    #enable the puppet agent service
    if $package_provider == 'gem' {
      $service_notify = Exec['puppet_agent_start']

      exec {
        'puppet_agent_start':
          command   => '/usr/bin/nohup puppet agent &',
          refresh   => '/usr/bin/pkill puppet && /usr/bin/nohup puppet agent &',
          unless    => "/bin/ps -ef | grep -v grep | /bin/grep 'puppet agent'",
          require   => File['/etc/puppet/puppet.conf'],
          subscribe => Package[$puppet_agent_name],
      }
    } else {
      $service_notify = Service[$puppet_agent_service]

      service { $puppet_agent_service:
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => File['/etc/puppet/puppet.conf'],
        subscribe => Package[$puppet_agent_name],
      }
    }
  } elsif $puppet_agent_service_enable == false and $puppet_agent_ensure == 'present' {

    #if puppet agent is run using cron or puppet commander, the service
    #remains disabled
    if $package_provider == 'gem' {
      exec {
        'puppet_agent_stop':
          command   => '/usr/bin/pkill puppet',
          onlyif    => "/bin/ps -ef | grep -v grep | /bin/grep 'puppet agent'",
      }
    } else {
      service { $puppet_agent_service:
        ensure    => stopped,
        enable    => false,
        hasstatus => true,
      }
    }
  }

  if $puppet_agent_ensure == 'present' {

    include concat::setup

    #ensure that the /etc/puppet directory is available
    if defined(File['/etc/puppet']) {
      File ['/etc/puppet'] {
        require +> Package[$puppet_agent_name],
        notify  +> $puppet::agent::service_notify,
      }
    }

    #setup up the puppet conf concat file
    if ! defined(Concat[$puppet_conf]) {
      concat { $puppet_conf:
        mode    => '0644',
        require => Package['puppet'],
        notify  => $puppet::agent::service_notify,
      }
    # } else {
    #   Concat<| title == $puppet_conf |> {
    #     require => Package['puppet'],
    #     notify  +> $puppet::agent::service_notify,
    #   }
    }

    if ! defined(Concat::Fragment['puppet.conf-common']) {
      concat::fragment { 'puppet.conf-common':
        order   => '00',
        target  => $puppet_conf,
        content => template("puppet/puppet.conf-common.erb"),
      }
    }
  }
}
