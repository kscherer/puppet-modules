# The site file for the puppet master server
$extlookup_datadir = "/etc/puppet/environments/${environment}/extdata/"
$extlookup_precedence = ['package', 'common']

#set the default path for all exec resources
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

# Define the bucket
filebucket {
  'main':
    server => $::server, path => false
}

# Specify it as the default target
File { backup => main }

#force the provider on RH 4 to be yum, not uptodate
if $::operatingsystem == 'RedHat' and $::operatingsystemrelease == '4' {
  Package { provider => yum }
}

# define nodes
import 'nodes.pp'

