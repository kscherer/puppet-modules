# The site file for the puppet master server
$extlookup_datadir = "$confdir/environments/$environment/extdata/"
$extlookup_precedence = ["package", "common"]

# Define the bucket
filebucket { main: server => $::server, path => false }

# Specify it as the default target
File { backup => main }

#force the provider on RH 4 to be yum, not uptodate
if $::operatingsystem == 'RedHat' and $::operatingsystemrelease == '4' {
  Package { provider => yum }
}

# define nodes
import "nodes.pp"

