# A class to hold common mcollective params for mcollective
class wr::mcollective (
  $client = false
  ) inherits wr::common {

  $amqp_server = $::hostname ? {
    /^ala.*$/ => 'ala-lpd-puppet.wrs.com',
    /^pek.*$/ => 'pek-lpd-puppet.wrs.com',
    /^yow.*$/ => 'yow-lpg-amqp.wrs.com',
  }

  $activemq_server1 = { host => $amqp_server, port => '6163',
                        user => 'mcollective', password => 'marionette'}

  $activemq_pool = { 1 => $activemq_server1 }

  class {
    '::mcollective':
      version               => 'latest',
      client                => $client,
      manage_plugins        => true,
      fact_source           => 'yaml',
      yaml_facter_source    => '/etc/mcollective/facter.yaml',
      mc_security_provider  => 'psk',
      mc_security_psk       => 'H5FFD^B*S0yc7JCp',
      main_collective       => 'mcollective',
      collectives           => "mcollective,${::location}",
      connector             => 'activemq',
      pool                  => $activemq_pool,
      plugin_params         => {
        'puppetca.puppetca' => '/usr/bin/puppet cert'
      }
  }

  #If this runs early then some data will be out of date for one run
  file { '/etc/mcollective/facter.yaml':
    ensure   => file,
    backup   => false,
    replace  => true,
    #grab all puppet vars from current scope, filter out invalid
    #or frequently changing values, make a yaml hash
    content  => inline_template("<%= scope.to_hash.reject {
      |k,v| !k.is_a?(String) || !v.is_a?(String) ||
      k.to_s =~ /(uptime|timestamp|free|path|rubysitedir|pubkey|ssh|module_name|caller_module_name)/
      }.to_yaml() %>")
  }

  cron {
    'restart_mcollective':
      command => '/sbin/service mcollective restart &> /dev/null',
      minute  => '0',
      hour    => '0';
  }
}
