#
class wr::yow_dns {
  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 128.224.144.130 \nnameserver 147.11.57.128\n";
  }
}
