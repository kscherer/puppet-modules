
# Class to install buildbot
class buildbot::slave {
  if $::operatingsystem == 'CentOS' {
    yumrepo {
      'buildbot':
        baseurl  => 'http://yow-mirror.wrs.com/mirror/buildbot',
        descr    => 'YOW Buildbot repo',
        enabled  => 1,
        gpgcheck => 0,
        notify   => Exec['yum-reload'];
    }

    package {
      'buildbot-slave':
        ensure  => latest,
        require => Yumrepo['buildbot'];
    }

    $bb_base = '/home/buildadmin/buildbot'
    file {
      [$bb_base,"$bb_base/slave"]:
        ensure => directory,
        owner  => buildadmin,
        group  => buildadmin;
    }

    exec {
      'create-buildbot-slave':
        require => [ File["$bb_base/slave"],
                    Package['buildbot-slave']],
        command => 'buildslave create-slave slave yow-lpgbld-master.wrs.com:9989 example-slave pass',
        path    => '/bin:/usr/bin:/sbin/',
        cwd     => $bb_base,
        user    => 'buildadmin',
        group   => 'buildadmin',
        creates => '$bb_base/slave/buildbot.tac';
      'start-buildbot-slave':
        require => [ File["$bb_base/slave"],
                    Package['buildbot-slave'], Exec['create-buildbot-slave']],
        command => 'buildslave start slave',
        path    => '/bin:/usr/bin:/sbin/',
        cwd     => $bb_base,
        user    => 'buildadmin',
        group   => 'buildadmin',
        #check if buildbot slave is running by checking for pid
        unless  => 'test ! -e slave/twistd.pid || test ! -d /proc/$(cat slave/twistd.pid)';
    }
  }
}
