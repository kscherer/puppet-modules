#
class git::service(
  $gitdir = '/git',
  $daemon = 'UNSET',
) {
  include git

  user {
    'git':
      ensure     => 'present',
      groups     => 'users',
      shell      => '/bin/bash',
      managehome => true;
  }

  group {
    'git':
      ensure => 'present';
  }

  #Only create the directory if not already created
  file {
    $gitdir:
      ensure  => directory,
      owner   => 'git',
      group   => 'git',
      replace => false;
  }

  include git::params

  $daemon_real = $daemon ? {
    'UNSET' => $git::params::daemon,
    default => $daemon,
  }

  ensure_resource('package', $git::params::daemon_package, {'ensure' => 'installed' })

  include xinetd

  xinetd::service {
    'git':
      disable        => 'no',
      port           => '9418',
      server         => $daemon_real,
      server_args    => "--base-path=${gitdir} --max-connections=64 --export-all --syslog --inetd --enable=upload-archive --enable=upload-pack --reuseaddr ${gitdir}",
      socket_type    => 'stream',
      protocol       => 'tcp',
      user           => 'git',
      group          => 'git',
      flags          => 'IPv6',
      log_on_failure => 'USERID',
  }

  Class['git::service'] -> Anchor['git::end']
}
