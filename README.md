Cron puppet module
==================

About
-----

This is a generic cron module for puppet.

The parameter `$jobs` is taken and wrapped with the `create_resources` function
as such this simply takes cron jobs with the standard puppet cron type
attributes.

If the `$heria_hash` parameter is true values for `$jobs` across all hierarchies
are used so cron jobs can be defined at multiple levels. This allows for a base
set of cron jobs to be defined at a low level of the hierarchy and more specific
cron jobs to be defined further up the hierarchy closer to what is likely more
relevant definitions.

There is also a `$defaults` parameter intended to minimise boiler plate. This
enables default attributes to be set once and applied for all puppet defined
cron jobs. In this module this is set to ensure the jobs is enabled and that
root is the user to execute the jobs.

Usage
-----

A basic example of adding some cron jobs

```puppet
include cron

$jobs = {
  first_jobs => {
    command   => '/bin/echo foo'
    hour      => '12'
  }
  second_jobs => {
    command   => '/bin/echo bar'
    hour      => '13'
  }
}
```

Dependancies
------------

This module depends upon `puppetlabs/stdlib` for validation checks.

