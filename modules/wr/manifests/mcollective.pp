# A class to hold common mcollective params for mcollective
class wr::mcollective (
  $client       = false,
  $registration = true
  ) {

  $amqp_server = hiera('amqp_server')

  $activemq_server1 = { host => $amqp_server, port => '6163',
    user => 'mcollective', password => 'marionette'}

  $activemq_pool = { 1 => $activemq_server1 }

  #mcollective 2.2 deb package does not have dependency on stomp
  if $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '12.04' {
    ensure_resource( 'package', 'ruby-stomp', {'ensure' => 'latest' })
    Package['ruby-stomp'] -> Package['mcollective']
  }

  anchor { 'wr::mcollective::begin': }
  -> class { 'wr::common': }

  -> class {
    '::mcollective':
      version                 => 'latest',
      client                  => $client,
      manage_plugins          => true,
      fact_source             => 'yaml',
      yaml_facter_source      => '/etc/mcollective/facter.yaml',
      mc_security_provider    => 'psk',
      mc_security_psk         => 'H5FFD^B*S0yc7JCp',
      main_collective         => 'mcollective',
      collectives             => "mcollective,${::location}",
      registration            => $registration,
      registration_collective => $::location,
      connector               => 'activemq',
      pool                    => $activemq_pool,
      plugin_params           => {
        'puppetca.puppetca'   => '/usr/bin/puppet cert'
      }
  }
  -> anchor { 'wr::mcollective::end': }

  cron {
    'restart_mcollective':
      ensure  => absent,
      command => '/sbin/service mcollective restart &> /dev/null',
      minute  => '0',
      hour    => '0';
    'generate_facts':
      command => '/usr/bin/facter --puppet --yaml > /etc/mcollective/facter.yaml 2> /dev/null',
      minute  => '0';
  }
}
