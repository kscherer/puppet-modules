# A class to hold common mcollective params for mcollective
class wr::mcollective (
  $client = false
  ) inherits wr::common {

  $collective = $::hostname ? {
    /^ala.*$/ => 'ala',
    /^pek.*$/ => 'pek',
    /^yow.*$/ => 'yow',
  }

  $amqp_server = $::hostname ? {
    /^ala.*$/ => 'ala-lpd-puppet.wrs.com',
    /^pek.*$/ => 'pek-lpd-puppet.wrs.com',
    /^yow.*$/ => 'yow-lpg-amqp.wrs.com',
  }

  #Previous bug with 12.04 and upstart has been fixed
  $mc_daemonize = '1'

  class {
    '::mcollective':
      version               => 'latest',
      client                => $client,
      manage_plugins        => true,
      fact_source           => 'yaml',
      yaml_facter_source    => '/etc/mcollective/facter.yaml',
      mc_security_provider  => 'psk',
      mc_security_psk       => 'H5FFD^B*S0yc7JCp',
      mc_daemonize          => $mc_daemonize,
      main_collective       => 'mcollective',
      collectives           => "mcollective,$collective",
      stomp_server          => $amqp_server,
      stomp_port            => '6163',
      stomp_user            => 'mcollective',
      stomp_passwd          => 'marionette',
      plugin_params         => {
        'puppetd.puppetd'   => '/usr/bin/puppet agent',
        'provision.puppetd' => '/usr/bin/puppet agent',
        'puppetca.puppetca' => '/usr/bin/puppet cert'
      }
  }

  #If this runs early then some data will be out of date for one run
  file { '/etc/mcollective/facter.yaml':
    ensure   => file,
    backup   => false,
    replace  => true,
    #grab all puppet vars from current scope, filter out invalid
    #or frequently changing values, make a yaml hash and then
    #sort the lines reverse alphabetically. Reverse so that --- stays
    #at the top of the file
    content  => inline_template("<%= scope.to_hash.reject {
      |k,v| !k.is_a?(String) || !v.is_a?(String) ||
      k.to_s =~ /(uptime|timestamp|free|path|rubysitedir|pubkey|ssh|module_name|caller_module_name)/
      }.to_yaml().split('\n').sort{ |x,y| y <=> x }.join('\n') %>")
  }

  cron {
    'restart_mcollective':
      command => 'service mcollective restart &> /dev/null',
      hour    => '0';
  }
}

