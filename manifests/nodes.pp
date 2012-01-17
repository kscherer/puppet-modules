node default {
}

node 'ala-lpd-puppet.wrs.com' {

  $stomp_server1 = { host1 => 'ala-lpd-puppet.wrs.com', port1 => '6163', user1 => 'mcollective',
    password1 => 'marionette' }

  class { redhat: }
  -> class { java: distribution => 'java-1.6.0-openjdk' }
  -> class { activemq: broker_name => 'ala-broker' }
  -> class {
    mcollective:
      client                => true,
      manage_plugins        => true,
      fact_source           => 'yaml',
      yaml_facter_source    => '/etc/mcollective/provisioned.yaml:/etc/mcollective/facter.yaml',
      mc_security_provider  => 'psk',
      mc_security_psk       => 'H5FFD^B*S0yc7JCp',
      main_collective       => 'mcollective',
      collectives           => 'mcollective,ala',
      stomp_pool            => { pool1 => $stomp_server1 },
      plugin_params         => {
        'puppetd.puppetd'   => '/usr/bin/puppet agent',
        'provision.puppetd' => '/usr/bin/puppet agent',
        'puppetca.puppetca' => '/usr/bin/puppet cert'
      }
  }
  -> class { wr::master: }
}

node 'pek-lpd-puppet.wrs.com' {

  $stomp_server1 = { host1 => 'pek-lpd-puppet.wrs.com', port1 => '6163', user1 => 'mcollective',
    password1 => 'marionette' }

  class { redhat: }
  -> class { java: distribution => 'java-1.6.0-openjdk' }
  -> class { activemq: broker_name => 'pek-broker' }
  -> class {
    mcollective:
      client                => true,
      manage_plugins        => true,
      fact_source           => 'yaml',
      yaml_facter_source    => '/etc/mcollective/provisioned.yaml:/etc/mcollective/facter.yaml',
      mc_security_provider  => 'psk',
      mc_security_psk       => 'H5FFD^B*S0yc7JCp',
      main_collective       => 'mcollective',
      collectives           => 'mcollective,pek',
      stomp_pool            => { pool1 => $stomp_server1 },
      plugin_params         => {
        'puppetd.puppetd'   => '/usr/bin/puppet agent',
        'provision.puppetd' => '/usr/bin/puppet agent',
        'puppetca.puppetca' => '/usr/bin/puppet cert'
      }
  }
  -> class { wr::master: }
}
