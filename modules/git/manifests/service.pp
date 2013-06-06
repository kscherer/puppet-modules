#
class git::service(
  $gitdir = '/git',
  $daemon = '/usr/bin/git-daemon',
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

  file {
    $gitdir:
      ensure => directory,
      owner  => 'git',
      group  => 'git',
  }

  include git::params

  ensure_resource('package', $git::params::daemon_package, {'ensure' => 'installed' })

  include xinetd

  xinetd::service {
    'tftp':
      disable        => 'no',
      port           => '9418',
      server         => $daemon,
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
