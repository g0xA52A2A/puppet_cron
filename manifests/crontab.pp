# This class takes parameters for the cron type and wraps them with the
# create_resources function to allow creation of N number of cron jobs.
#
# The parameters $jobs, $defaults, $hiera_hash and $purge are taken.
#
# $jobs should be a nested hash of cron jobs using the standard attributes for
# the puppet cron type.
#
# $defaults should also be a hash of the puppet cron type attributes. If values
# are specified in both $defaults and $jobs the value in $jobs takes precedence.
#
# $hiera_hash is a boolean, if true it enables lookup of values in all level of
# the hierarchy. This allows you to define a set of common cron jobs at a low
# level and node or group specific jobs at a higher level. The default hiera
# behaviour would only match the first entry in the 'closest' hierarchy.
#
# Purge is set to false by default, but if set to true only crontab entries from
# puppet will be permitted on the system.

class cron::crontab

(
$jobs = undef,
$defaults = {ensure => present, user => root},
$hiera_hash = false,
$purge = false,
)

{

  # Validate the parameters passed to the module to fail quickly rather than
  # passing create_resources invalid options

  validate_hash($defaults)
  validate_bool($hiera_hash, $purge)

  # $cron_jobs is used as an interim as puppet does not allow us to
  # reassign variables

  if $cron::hiera_hash == true {
    $cron_jobs = hiera_hash('cron::crontab::jobs')
  }
  elsif $hiera_hash == true {
    $cron_jobs = hiera_hash('cron::crontab::jobs')
  }
  else {
    $cron_jobs = $jobs
  }

  # $cron_purge is used as an interim as puppet does not allow us to
  # reassign variables

  if $cron::purge == true {
    $cron_purge = $cron::purge
  }
  else {
    $cron_purge = $purge
  }

  # Using if as init.pp includes this but the user may not pass any parameters
  # to this class for jobs. As such only create jobs is a hash is received. If
  # not a hash or anything other than undef is received fail and print some
  # useful output.

  if is_hash($cron_jobs) == true {
    create_resources(cron, $cron_jobs, $defaults)
  }
  elsif $cron_jobs != undef {
    $type = type($cron_jobs)
    fail ("\$jobs was expected hash or undef, got ${cron_jobs} type:${type}")
  }

  resources { 'cron':
  purge => $cron_purge
  }

}

