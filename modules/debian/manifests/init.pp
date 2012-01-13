
#
class debian {
  include exim4

  package {
    "unattended-upgrades":
      ensure => latest;
  }

  #koan needs the following packages
  if $operatingsystem == "Debian" {

    include xen

    package {
      [ 'yum', 'python-simplejson', 'parted' ]:
        ensure => installed;
    }

    # install collectd on all dom0 machines to monitor vms
    include collectd::client

    class { 'apt': }

    #fix the release to debian squeeze
    case $kernelmajversion {
      /^3.*/: { class { 'apt::release' : release_id => "unstable" } }
      default: { class { 'apt::release' : release_id => "stable" } }
    }

    apt::source {
      "yow-mirror_squeeze":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/debian/",
        release => "squeeze",
        repos => "main contrib non-free",
        include_src => false,
        required_packages => "debian-keyring debian-archive-keyring",
        key => "55BE302B",
        key_server => "subkeys.pgp.net";
      "yow-mirror_testing":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/debian/",
        release => "testing",
        include_src => false,
        repos => "main contrib non-free";
      "yow-mirror_unstable":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/debian/",
        release => "unstable",
        include_src => false,
        repos => "main contrib non-free";
      "yow_apt_mirror":
        location => "http://yow-lpgbld-master.ottawa.windriver.com/apt/",
        release => "squeeze",
        include_src => false,
        repos => "main";
    }

    file {
      "01puppet":
        owner => 'root', group => 'root', mode => '644',
        path => '/etc/apt/preferences.d/01puppet',
        source => 'puppet:///modules/master/01puppet';
      '/root/partition_drives.sh':
        owner => 'root', group => 'root', mode => '700',
        source => 'puppet:///modules/debian/partition_drives.sh';
    }
  }

  package {
      "libshadow-ruby1.8":
         ensure => installed;
  }

  file {
    '/etc/apt/apt.conf.d/90aptitude':
      content => 'Aptitude "";
Aptitude::CmdLine "";
Aptitude::CmdLine::Show-Versions "true";
Aptitude::CmdLine::Package-Display-Format "%c%a%M %p# - %d%V#";',
      ensure => file;
  }

  #force the default shell to be bash
  if $operatingsystem == "Ubuntu" {

    class { 'apt': }

    apt::source {
      "yow-mirror_ubuntu":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/",
        release => "$lsbdistcodename",
        repos => "main restricted universe",
        include_src => false;
      "yow-mirror_ubuntu_security":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/",
        release => "${lsbdistcodename}-security",
        repos => "main restricted universe",
        include_src => false;
      "yow-mirror_ubuntu_updates":
        location => "http://yow-mirror.ottawa.windriver.com/mirror/ubuntu.com/ubuntu/",
        release => "${lsbdistcodename}-updates",
        repos => "main restricted universe",
        include_src => false;
      "yow_apt_ubuntu_mirror":
        location => "http://yow-lpgbld-master.ottawa.windriver.com/apt/",
        release => "lucid",
        include_src => false,
        repos => "main";
    }

    exec { "bash_setup":
      path => "/usr/bin:/usr/sbin:/bin",
      command => "echo 'dash    dash/sh boolean false' | debconf-set-selections; dpkg-reconfigure -pcritical dash",
      onlyif => "test `readlink /bin/sh` = dash"
    }
  }

  remotefile {
    "/etc/apt/apt.conf.d/02periodic":
      module => "debian";
    "/etc/apt/apt.conf.d/50unattended-upgrades":
      module => "debian";
    "/etc/apt/public.key":
      module => "debian";
  }

  exec { "install-key":
    command => "/usr/bin/apt-key add /etc/apt/public.key",
    require => File["/etc/apt/public.key"],
    unless  => "/usr/bin/apt-key list | /bin/grep -q 'Konrad.Scherer'";
  }

  exec { "key-update":
    command => "/usr/bin/apt-get update",
    require => Exec["install-key"],
    refreshonly => "true";
  }
}
