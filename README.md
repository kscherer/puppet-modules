# Wind River Puppet modules

These are the puppet modules used by the Linux Infrastructure team at
[Wind River](http://windriver.com/products/linux.html)

## Wind River puppet module workflow

All the puppet modules and hiera data are stored in git. I have
created a post receive hook that automatically syncs the three puppet
masters yow-lpd-puppet2, ala-lpd-puppet and pek-lpd-puppet.

The git hook maps git branches to puppet environments as originally
suggested on the PuppetLabs [blog](https://puppetlabs.com/blog/git-workflow-and-puppet-environments/)

The default branch is production. If a change could affect systems
using the production branch the easist way to test is to create a new
branch/environment.

1. Create a local clone of the wr-puppet-modules repo:

        git clone --branch production \
        ssh://ala-git.wrs.com/users/buildadmin/wr-puppet-modules

1. Make test environment. Note that the branch name must contain only
   letters, numbers and underscore; dashes are not accepted by puppet:

        git checkout -b myenv production

1. Modify modules. Start with manifests/nodes.pp to add your machines.

1. Commit the changes and push to ala-git:

        git add -A; git commit -m "My first puppet environment"
        git push origin myenv

1. Run puppet agent on the test system:

        puppet agent --test --environment myenv


## Structure

This repo uses git subtree to track external modules. The git subtree
script is located in git/contrib directory.

I have made significant changes to many of these external modules. I
have submitted pull requests for some and hope to work with upstream
to integrate the changes that are deemed useful.

The puppet infrastructure uses branches as environments, which is why
the main branch is production, not master.

Many of the modules are from GitHub. I use git subtrees to import
individual modules, but also give me a way to use the same repo to
push changes to GitHub for pull requests.

For example to add the logrotate module, import the remote repo as a
directory.

    git subtree add --prefix=modules/logrotate --squash git://github.com/rodjek/puppet-logrotate.git master

Note that the --squash option is necessary to avoid having all the
commits from the upstream repo in the production branch

Now if upstream changes (using postgresql module as example):

    git subtree pull --squash -m "Update postgres" \
      --prefix modules/postgresql \
      https://github.com/puppetlabs/puppetlabs-postgresql.git master

This works but makes working with upstream a little more difficult. So
a better workflow is to clone the repo on GitHub, make a windriver
branch and use that as the subtree. Then any useful patches can be
added to other branches and submitted as pull requests.

Sometimes the subtree pull will fail and the only fix is to delete the
directory and add the subtree again.

    git rm -f modules/logrotate
    git add -A
    git commit -m "Removing outdated logrotate module in preparation
    for new subtree"
    git subtree add ...

## Organization

Most of the Wind River specific system configuration is in
modules/wr.
