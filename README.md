# Wind River Puppet modules

These are the puppet modules used by the Linux Infrastructure team at
[Wind River](http://windriver.com/products/linux.html)

## Structure

This repo uses subgits to track external modules. I have made
significant changes to many of them. I have submitted pull requests
for some and hope to work with upstream to integrate the changes that
are deemed useful.

The puppet infrastructure uses branches as environments, which is why
the main branch is production, not master.

Many of the modules are from the puppet forge and GitHub. I use git
subtrees to import individual modules, but also give me a way to use
the same repo to push changes to GitHub for pull requests.

For example to add the logrotate module, first tell git where the
module is located and automatically fetch it.

    git remote add -f logrotate git://github.com/rodjek/puppet-logrotate.git

Now make a local tree which represents the upstream state. It is a
little confusing because the branch looks completely different than
the production branch.

    git checkout -b logrotate logrotate/master
    git checkout production

As far as I can tell, the following command will wrap the import of
the subtree in a merge commit. I did not do this for a while and had
problems doing merges, so I am trying it to see if it helps.

    git merge -s ours --no-commit logrotate

Here is the git magic. "Mount" the tree into a directory of the main branch

    git read-tree --prefix=modules/logrotate -u logrotate
    git commit -m "Added logrotate module"

Now if upstream changes:

    git checkout logrotate
    git pull
    git checkout production
    git merge --squash -s subtree logrotate
    git commit -m "Sync with logrotate upstream"

To submit changes upstream

    git checkout -b logrotate_local logrotate
    git merge --squash -s subtree production
    git commit -m "Submit patch to logrotate upstream"
    git push github logrotate_local

Now go make a pull request on GitHub.

## Organization

Most of the Wind River specific system configuration is in
modules/wr.
