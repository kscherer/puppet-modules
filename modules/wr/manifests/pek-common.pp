#
class wr::pek-common {
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }

  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 128.224.160.12 \nnameserver  128.224.160.11\n";
  }

}
