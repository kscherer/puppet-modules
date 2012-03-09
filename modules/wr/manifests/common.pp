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
}
