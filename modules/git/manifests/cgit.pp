#
class git::cgit {

  if $::operatingsystem == 'Ubuntu' {
    apt::ppa { 'ppa:kmscherer/cgit': }
    Apt::Ppa['ppa:kmscherer/cgit'] -> Package['cgit']
  }

  package {
    ['cgit', 'highlight']:
      ensure => installed;
  }

  file {
    '/etc/cgitrc':
      ensure   => present,
      content => template('puppet:///modules/git/cgitrc.erb');
    '/home/git/generate_cgit_repolist.sh':
      ensure => present,
      owner  => 'git',
      group  => 'git',
      source => 'puppet:///modules/git/generate_cgit_repolist.sh';
  }

  cron {
    'generate_cgit_repolist':
      ensure  => present,
      command => 'export OUTPUT=`mktemp`; /home/git/generate_cgit_repolist.sh > $OUTPUT; mv $OUTPUT /home/git/repos.list; chmod 644 /home/git/repos.list',
      user    => 'git',
      minute  => '0';
  }
}
