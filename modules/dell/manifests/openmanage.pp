#
# == Class: dell::openmanage
#
# Install openmanage tools
#
class dell::openmanage {

  include ::dell::hwtools

  service { 'dataeng':
    ensure    => running,
    hasstatus => true,
  }

  file {'/etc/logrotate.d/openmanage':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "# file managed by puppet
/var/log/TTY_*.log {
  missingok
  weekly
  notifempty
  compress
}
",
  }

  file {'/etc/logrotate.d/perc5logs':
    ensure  => absent,
  }

  tidy {'/var/log':
    matches => 'TTY_*.log.*',
    age     => '60d',
    backup  => false,
    recurse => true,
  }

  case $::osfamily {
    RedHat: {

      # openmanage is a mess to install on redhat, and recent versions
      # don't support older hardware. So puppet will install it if absent,
      # or else leave it unmanaged.
      include ::dell::openmanage::redhat
      Class['::dell::openmanage::redhat'] -> Class['::dell::openmanage']

      augeas { 'disable dell yum plugin once OM is installed':
        changes => [
          'set /files/etc/yum/pluginconf.d/dellsysidplugin.conf/main/enabled 0',
          'set /files/etc/yum/pluginconf.d/dellsysid.conf/main/enabled 0',
        ],
        require => Service['dataeng'],
      }
      case $::architecture {
        /i.86/: { $libdir = 'lib' }
        default:{ $libdir = 'lib64'}
      }

      file {
        "/opt/dell/srvadmin/${libdir}/openmanage/IGNORE_GENERATION":
          ensure => present;
        '/opt/dell/srvadmin/var/lib/srvadmin-deng/dcsnmp.off':
          ensure => absent;
      }

      augeas {
        'Enable openmanage snmp integration':
          changes => [
            'set /files//opt/dell/srvadmin/etc/srvadmin-omilcore/install.ini/installed/SNMP enabled',
          ],
          notify  => Service['dataeng'],
      }

    }

    Debian: {
      include ::dell::openmanage::debian
    }

    default: {
      err("Unsupported operatingsystem: ${::operatingsystem}.")
    }

  }

}
