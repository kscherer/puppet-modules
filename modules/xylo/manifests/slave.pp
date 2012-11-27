#
class xylo::slave {

  #make a link to the service name
  file {
    '/buildarea':
      ensure => directory,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755';
  }

  cron {
    'slave_cleanup':
      environment => 'MAILTO="paul.kennedy@windriver.com wenzong.fan@windriver.com"',
      command     => '/stored_builds/xylo/scripts/slave_clean',
      user        => buildadmin,
      minute      => 28;
  }
}
