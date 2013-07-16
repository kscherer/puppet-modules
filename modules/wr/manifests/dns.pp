#
class wr::dns(
  $static      = false,
  $nameservers = hiera_array('nameservers')
) {

  #All CentOS servers have static network configuration
  if $static == true or $::operatingsystem == 'CentOS' {
    file {
      '/etc/resolv.conf':
        ensure  => present,
        mode    => '0644',
        content => template('wr/resolv.conf.erb');
    }
  }
}
