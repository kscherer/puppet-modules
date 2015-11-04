# Wind River Puppet modules

These are the puppet modules used by the Linux Infrastructure team at
[Wind River](http://windriver.com/products/linux.html)

The documentation has been moved to the standard Linux documentation repo:

http://lpd-web.wrs.com/wr-process/master/puppet_git_workflow.html

## Testing with Docker

Run docker image with puppet preinstalled:

    docker run -it --rm \
        -v /home/kscherer/repos/wr-puppet-modules:/opt/puppet \
        kscherer/puppet /bin/bash

To run puppet apply with the same hiera and module path:

    apt-get update
    env FACTER_location=yow FACTER_hiera_datadir=/opt/puppet/hiera/ \
    puppet apply \
        --modulepath=/opt/puppet/modules:/opt/puppet/external \
        --hiera_config=/opt/puppet/hiera/hiera.yaml \
        -e "include profile::base"
