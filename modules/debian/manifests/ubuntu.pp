#
class debian::ubuntu {

  apt::source {
    'yow-mirror_ubuntu':
      location    => 'http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/',
      release     => $::lsbdistcodename,
      repos       => 'main restricted universe',
      include_src => false;
    'yow-mirror_ubuntu_security':
      location    => 'http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/',
      release     => "${::lsbdistcodename}-security",
      repos       => 'main restricted universe',
      include_src => false;
    'yow-mirror_ubuntu_updates':
      location    => 'http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/',
      release     => "${::lsbdistcodename}-updates",
      repos       => 'main restricted universe',
      include_src => false;
    'yow_apt_ubuntu_mirror':
      location    => 'http://yow-lpgbld-master.ottawa.windriver.com/apt/',
      release     => $::lsbdistcodename,
      include_src => false,
      repos       => 'main';
    'puppetlabs_apt_mirror':
      location    => 'http://apt.puppetlabs.com/',
      release     => $::lsbdistcodename,
      include_src => false,
      repos       => 'main';
  }

  #force the default shell to be bash
  exec {
    'bash_setup':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => 'echo \'dash    dash/sh boolean false\' | debconf-set-selections; dpkg-reconfigure -pcritical dash',
      onlyif  => 'test `readlink /bin/sh` = dash'
  }
}
