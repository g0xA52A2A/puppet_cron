Cron puppet module
==================

About
-----

This is a generic cron module for puppet.

#### init.pp

This contains the main cron class and simply ensures that cron is running.

### crontab class

The parameter `$jobs` is taken and wrapped with the `create_resources` function
as such this simply takes cron jobs with the standard puppet cron type
attributes.

There is also a `$defaults` parameter intended to minimise boiler plate. This
enables default attributes to be set once and applied for all puppet defined
cron jobs. In this class this is set to ensure the jobs is enabled and that
root is the user to execute the jobs.

### hourly, daily, weekly and monthly classes

These are similar to the crontab class but differ in that it is taking the
puppet file type for the `$jobs`.
To provide a consistant interface you simply need to specify the name of the job
and the command to execute. This will likely be the same as jobs passed to the
crontab class. See examples below.

Note: Creating jobs via parameters for these classes requires `parser = future`.

These classes also support pulling files from the files directory of the module
itself on the puppet master. For example placing a file in `files/hourly` would
result in the client picking up that file in `/etc/cron.hourly/`.

### hiera_hash

If the `$heria_hash` parameter is true values for `$jobs` across all hierarchies
are used so cron jobs can be defined at multiple levels. This allows for a base
set of cron jobs to be defined at a low level of the hierarchy and more specific
cron jobs to be defined further up the hierarchy closer to what is likely more
relevant definitions.
This is definable in each of the classes. If defined in the main cron class as
true it will take precedence over definitions in other classes.

### purge

All classes with the exception of the main cron class take a `$purge` parameter
which if set to true will cause puppet to remove any cron jobs that are not
provided by puppet.

Usage
-----

A basic example of adding some cron jobs in YAML.

```yaml
# Add two cron jobs to crontab

cron::crontab::jobs: 
  first_job: 
    command:  '/bin/echo "This is run as root every 12 hours"'
    hour:     '12'
  second_job: 
    command:  '/bin/echo "This is run as puppet every 12 hours"'
    hour:     '12'
    user:     'puppet'

# Only allow puppet controlled jobs in /etc/cron.daily

cron::daily::pruge: 'true'

# Add job to /etc/cron.daily/

cron::daily::jobs: 
  once_a_day: 
    command: '/bin/echo "Today is $(/bin/date)"'

```

Dependencies
------------

This module depends upon `puppetlabs/stdlib` for validation checks.

