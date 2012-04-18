#
class wr::common {
  #Make sure that the machine is in the hosts file
  host {
    $::fqdn:
      ip           => $::ipaddress,
      host_aliases => $::hostname;
    'localhost':
      host_aliases => 'localhost.localdomain',
      ip           => '127.0.0.1';
  }

  $kscherer_windriver_pubkey = 'AAAAB3NzaC1kc3MAAACBAIbOZM9uCzc7Zt4Ux8wgVNNaRFwY2WAQDOy2s5mkBngD4wlb+W67lAo6rgBUhCv1iY8wYLouiMHvctS1SmBpZFgrj6TY4PK2OxHze/7ac/ZnxAh3teH28XRN8x1ubMQ0HCQo2uaAtDhNDx5dSUxYZjvBZlR2oVpJkyy0I937+csbAAAAFQCEzu6rNLZw4bw2p7KR7kQc+606AwAAAIAl0Z9dhOUfso3KaN2loIFuzL5kn7mqkfHGwhkchHuVzY30lzf3GgcNAJQTHyDBHilQQxXZAEuUkeDongEoPDrmYGFe0yEzz/OclpsWh1R9L6oAS+7K+gs8UfDeqecBE3Ohm8lyAw2xDAb99kWIWfiiquQtWNjiPdT9wuXkdj4ZegAAAIAzBiUn6Vje9musJKyNhOOjGaOiGIbsqH4wIdHEPiPghx8ADuK+W01SbMo6zIWvibXMU0Q/bCNL/jBoe7cPGtjoLJQ5a1UIySufuRKfo6cv2QtWTUErJOJOL85TLSybz8YOuBo/TMJYr77gROf4SYhJMb0UFDQwkiOL/t6hCL8zhQ=='

  $kscherer_home_pubkey = 'AAAAB3NzaC1yc2EAAAABIwAAAQEAoMAWBsZ+dbQWeRYZ8y2Vtdk7nbcK4HaL2Ael/HxRCgcDBIBkJOU80pizQWq3JstUI0Ls9zCywcKpISOuSBp/3OVHsAExMK6gwiyLn/Rq7NT2I9xZ2jSgFltGi/b9x/+QrUvQ1yq7otv0fFrwhKNbpb11nCJR0CcXFGcQD4kgdmQd+4DAbhvHICBn1041CQWFrWKGfd5maLL1l+cghr0/qNcTr9Fxi81zhqEsT2VJRjacho7qaWJl3xT7l2Lg4Al/qECQRs32NHF8fmbO7eZsBawnwp+gWsabAXWwn28GCQNLGtURxPCKwWJ2RfGOZ5sXmRehg39/9Vxxq8wQnFkiGQ=='

  $cobbler_admin_pubkey = 'AAAAB3NzaC1kc3MAAACBAMb5EgnAoaBxuP3GNDlqeQ/ydZgR2JtPqiDFm4d06CaFG45fzsl6AQbouCdLeUiK5rVdfMqUwpcwH7+4K2k3ZgLy7JlwpB5YCoqre/zvky0vDAJS3Yd/NhPbdvEnSnWHpGKrYEvWLOzC0QGY67g1urImsX6bFwmEVRzRd7GH2Kg9AAAAFQDnKcDpZGbGQlBfnDnLOfHVgvimIQAAAIBGIaanpIP1uCX1GeUTyitOgSq3by8sELg5bKwWpYUDpDfOEWvUXvzWXFrP/SWNsxxeUYNSfNKPYDXbRSSwbIlIipI1AgZGUMpyvqLWqdjEo2nwY5MhNOF7Ye8gN1kQ8OQ7RD3ay6SVsz2kvo3WzAdaEgvumpiO0B8gV93BPTyQTQAAAIEAiA0nZlIQk9TecDXBY3OCtzrQ5j1upB0dscqwj0YJ2FP4cx8rn3rJDBXTbDLeiIo+brh/UazRd85MODREXY4Kx5tSoqjuLkqoV17Fj1ijnkovfwfvi/CR0oa57DhZbPsGwX33yKrn/8x/B+nOqAs5qG7dXyO7TQearLjldHL7TyQ='

  $wenzong_pubkey = 'AAAAB3NzaC1kc3MAAACBAPBhyTlAahJYPtONvfe44DCN9rKgpFTsus0KyJVe4QPW9V1bnT+CB5hWhw9pst0hB0Kih++D+Ew9Ev1gt7zodtg1VaVOgl4ATkbesMMSJZ0iF7/T5twmWAz/SI+qogn8jFcTRzvbXG+kvvZLQ8d7bDiGmSWcf6IJzAl+MsGZRwEvAAAAFQDQcuZ532wEdLXueGuUEhZjUiHt6QAAAIBjjxkD1SXLF5gd03fqYvM8+/Iu9+qgwtsfzwRgOBGeOjtknopuhWM+hWtZuLvcqd4QXBFmNHBZOLJs0RzJ4DhwuptwWI/LMOL+L+9LFOeSAn2SHxJEOuGO6rxEYCMj4nB7SKG6TkyH4GqvnJAML2yTnj9pc+UC88Q9IIBwG3yKQgAAAIEAihIaDA4oHROB9aVuIiD7nHNrE8ZNog+u3MEwuRAHvBTXTcIscjqTcOJshkkZJMyKZzbPBvUYyVy2jPFKZE9OeTTeLuVioQqjBdJ/AlNkoRgBssP7N+VHaajt5rd42gCB2503r6nIkpVkeISD/PRLSb+RlKdftjHKUtE+3Aot2eo='

  ssh_authorized_key {
    'kscherer_windriver':
      ensure => 'present',
      user   => 'root',
      key    => $kscherer_windriver_pubkey,
      type   => 'ssh-dss';
    'kscherer_home':
      ensure => 'present',
      user   => 'root',
      key    => $kscherer_home_pubkey,
      type   => 'ssh-rsa';
    'cobbler_admin':
      ensure => 'present',
      user   => 'root',
      key    => $cobbler_admin_pubkey,
      type   => 'ssh-dss';
  }

  #The puppet package get handled by puppet module, but not facter
  package {
    'facter':
      provider => $::operatingsystem ? {
        /(OpenSuSE|SLED)/        => 'gem',
        /(RedHat|Fedora|CentOS)/ => 'yum',
        default                  => undef,
      },
      ensure   => latest;
  }

  #This path is used for stdlib facter_dot_d module
  file {
    '/etc/facter/':
      ensure => directory;
    '/etc/facter/facts.d/':
      ensure => directory;
  }

  #boolean variables from facter may be strings
  $is_virtual_bool = any2bool($::is_virtual)

  #Another bug on some systems where is_virtual=false
  if $is_virtual_bool == false and $::hostname =~ /^yow-lpgbld-vm\d\d/ {
    file_line {
      'facter_xen_detect_workaround':
        path   => '/etc/fstab',
        line   => 'xenfs /proc/xen xenfs defaults 0 0',
        notify => Exec['remount_all'];
    }
    exec {
      'remount_all':
        command     => '/bin/mount -a',
        refreshonly => true
    }
  }

  #if vm is using older version of xen, give each vm its own independent clock.
  #in later versions of xen, this is the default so just assume each machine
  #will be running ntp
  if $is_virtual_bool == true {
    exec {
      'xen_independent_clock':
        command  => 'echo 1 > /proc/sys/xen/independent_wallclock',
        path     => '/usr/bin:/usr/sbin/:/bin',
        onlyif   => 'test `cat /proc/sys/xen/independent_wallclock` = \'0\'';
    }
  }

  #set the puppet server based on hostname
  $puppet_server = $::hostname ? {
    /^ala.*$/ => 'ala-lpd-puppet.wrs.com',
    /^pek.*$/ => 'pek-lpd-puppet.wrs.com',
    /^yow.*$/ => 'yow-lpd-puppet.wrs.com',
  }

  $ntp_servers = $::hostname ? {
    yow-lpgbld-master => ['ntp-1.wrs.com','ntp-2.wrs.com'],
    /^yow-lpgbld-.*/  => ['yow-lpgbld-master.wrs.com'],
    default           => ['ntp-1.wrs.com','ntp-2.wrs.com'],
  }

  #add my configs to all machines
  file {
    '/root/.bashrc':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/root/.aliases':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/root/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }

}
