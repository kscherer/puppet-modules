#
class suse {
  ensure_resource( 'package', 'lsb-release', {'ensure' => 'installed' })

  if $::operatingsystem == 'OpenSuSE' {

    exec { 'zypper_refresh':
      command     => '/usr/bin/zypper refresh',
      refreshonly => true
    }

    #only puppet managed repo files in /etc/zypp/repos.d
    file {
      '/etc/zypp/repos.d/':
        ensure  => directory,
        recurse => true,
        purge   => true,
        owner   => root,
        group   => root,
        notify  => Exec['zypper_refresh'];
    }

    $mirror_host = hiera('mirror')
    $mirror = "http://${mirror_host}/mirror"
    $opensuse_dist = "${mirror}/opensuse/distribution/${::operatingsystemrelease}/repo/oss/suse"
    $opensuse_updates = "${mirror}/opensuse/update/${::operatingsystemrelease}"
    $opensuse_puppet = "${mirror}/opensuse/puppet/openSUSE_${::operatingsystemrelease}/"

    zypp_repo {
      'opensuse':
        baseurl => $opensuse_dist;
      'opensuse-updates':
        baseurl => $opensuse_updates;
    }

    #Special puppet repo only available for 12.1+
    if versioncmp($::operatingsystemrelease, '12') > 0  {
      zypp_repo {
        'opensuse-puppet':
          baseurl => $opensuse_puppet;
      }
    }
    if versioncmp($::operatingsystemrelease, '13.2') >= 0  {
      zypprepo {
        'server:monitoring':
          baseurl => 'http://download.opensuse.org/repositories/server:/monitoring/openSUSE_13.2/',
          descr       => 'Server Monitoring Software (openSUSE_13.2)',
          enabled     => '1',
          autorefresh => '1',
          gpgcheck    => '1',
          gpgkey      => 'http://download.opensuse.org/repositories/server:/monitoring/openSUSE_13.2/repodata/repomd.xml.key';
      }
    }
  }
}
