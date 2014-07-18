#ovirt

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ovirt](#setup)
    * [What ovirt affects](#what-ovirt-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ovirt](#beginning-with-ovirt)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Overview

The ovirt module provides the installation procedure for oVirt including the setup of
the engine and the nodes.

##Module Description

The SSMTP module prelace the standard mail server configuration with a light
wight sending only server. The behavior is the same as sendmail but without
the possibility to recieve mails from external systems.


##Setup

###What ovirt affects

* ovirt package.
* ovirt configuration file.
* ovirt alternative service configuration.

###Beginning with ovirt

include '::ovirt' is enough to get you up and running if the parameters point to
proper values.  If you wish to pass in parameters like which servers to use then you
can use:

```puppet
class { '::ovirt':
  mailHub => 'mail.example.local',
}
```

##Usage

All interaction with the ovirt module can do be done through the main ovirt class.
This means you can simply toggle the options in the ovirt class to get at the full
functionality.

###I just want SSMTP, what's the minimum I need?

```puppet
include '::ovirt'
```

###I just want to route all mails to central mail gateway, nothing else.

```puppet
class { '::ovirt':
  mailHub => 'mail.example.local',
  rootEmail => 'john.doe@example.local',
}
```


##Reference

###Classes

* ovirt: Main class, includes all the rest.
* ovirt::install: Handles the packages.
* ovirt::config: Handles the configuration file.
* ovirt::service: Handles the alternative service link.

###Parameters

The following parameters are available in the ovirt module

####`defaultMta`

Replace the default MTA with ovirt if set to ovirt.

####`rootEmail`

Specify which Email address should recieve all mails from root.

####`mailHub`

Define the mail server which should deliver all mails.

####`revaliases`

Array to define the reverse aliases.


##Limitations

This module has been built on and tested against Puppet 3.2 and higher.

The module has been tested on:

* RedHat Enterprise Linux 6
* Scientific Linux 6

Testing on other platforms has been light and cannot be guaranteed. 


##Development

If you like to add or improve this module, feel free to fork the module and send
me a merge request with the modification.
