#
class profile::nis inherits profile::monitored {
  include ::nis
  include sudo

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
    'leads':
      source  => 'puppet:///modules/wr/sudoers.d/leads';
    'it':
      source  => 'puppet:///modules/wr/sudoers.d/it';
  }

  # Add CDC IT staff as sudoers to machines in CDC
  if $::location == 'pek' {
    sudo::conf {
      'cdc_it':
        source  => 'puppet:///modules/wr/sudoers.d/cdc_it';
    }
  }

  if $::location == 'otp' {
    sudo::conf {
      'itotp':
        source  => 'puppet:///modules/wr/sudoers.d/itotp';
    }
  }

  Class['wr::common::repos'] -> Class['::nis']
  Class['wr::common::repos'] -> Class['::nfs::client']
  Class['wr::common::repos'] -> Class['sudo']
}
