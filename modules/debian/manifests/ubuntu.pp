#
class debian::ubuntu ( $mirror_base ) {

  $ubuntu_mirror = "${mirror_base}/ubuntu.com/ubuntu"

  #Sources are managed by puppet only
  class {'apt': purge_sources_list => true }

  apt::source {
    'yow-mirror_ubuntu':
      location    => $ubuntu_mirror,
      release     => $::lsbdistcodename,
      repos       => 'main restricted universe',
      include_src => false;
    'yow-mirror_ubuntu_security':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-security",
      repos       => 'main restricted universe',
      include_src => false;
    'yow-mirror_ubuntu_updates':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-updates",
      repos       => 'main restricted universe',
      include_src => false;
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main dependencies';
  }

  #force the default shell to be bash
  exec {
    'bash_setup':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => 'echo \'dash    dash/sh boolean false\' | debconf-set-selections; dpkg-reconfigure -pcritical dash',
      onlyif  => 'test `readlink /bin/sh` = dash'
  }
}
