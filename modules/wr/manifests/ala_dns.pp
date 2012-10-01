#
class wr::ala_dns {
  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 147.11.57.128\nnameserver 147.11.57.133\n";
  }
}
