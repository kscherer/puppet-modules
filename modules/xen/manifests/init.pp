#
class xen {

  $xen_version = $::lsbdistcodename ? {
    'squeeze' => '4.0',
    default   => '4.1',
  }

  file { '/var/lib/xen' :
    ensure => link,
    target => "/usr/lib/xen-${xen_version}"
  }

  file { 'xend-config' :
    path   => '/etc/xen/xend-config.sxp',
    mode   => '0640',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/xen/xend-config.sxp',
    notify => Service['xend']
  }

  package { "xen-utils-${xen_version}" :
    ensure => installed,
    notify => Service['xend']
  }

  service { 'xend' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    status     => 'xend status',
    hasstatus  => false;
  }

  #make sure necessary xen modules are loaded
  case $::kernelmajversion {
    /^3.*/: {
      xen::module {
        ['xen_gntdev','xen_gntalloc','xen_netback','xen_blkback']:
      }
    }
    default: { }
  }
}
