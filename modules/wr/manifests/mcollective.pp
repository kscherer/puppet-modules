# A class to hold common mcollective params for mcollective
class wr::mcollective {

  $collective = $::hostname ? {
    /^ala-.*$/ => 'ala',
    /^pek-.*$/ => 'pek',
    /^yow-.*$/ => 'yow',
  }

  $puppet_server = $::hostname ? {
    /^ala-.*$/ => 'ala-lpd-puppet.wrs.com',
    /^pek-.*$/ => 'pek-lpd-puppet.wrs.com',
    /^yow-.*$/ => 'yow-lpgbld-master.ottawa.wrs.com',
  }

  $stomp_server = { host1 => "$puppet_server", port1 => '6163', user1 => 'mcollective',
    password1 => 'marionette' }

  class {
    mcollective:
      client                => true,
      manage_plugins        => true,
      fact_source           => 'yaml',
      yaml_facter_source    => '/etc/mcollective/provisioned.yaml:/etc/mcollective/facter.yaml',
      mc_security_provider  => 'psk',
      mc_security_psk       => 'H5FFD^B*S0yc7JCp',
      main_collective       => 'mcollective',
      collectives           => "mcollective,$collective",
      stomp_pool            => { pool1 => $stomp_server },
      plugin_params         => {
        'puppetd.puppetd'   => '/usr/bin/puppet agent',
        'provision.puppetd' => '/usr/bin/puppet agent',
        'puppetca.puppetca' => '/usr/bin/puppet cert'
      }
  }
}

