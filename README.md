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

## Organization

Most of the Wind River specific system configuration is in
modules/wr.
