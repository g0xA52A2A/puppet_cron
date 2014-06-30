# This class takes parameters for the cron type and wraps them with the
# create_resources function to allow creation of N number of cron jobs.
#
# The parameters $jobs, $defaults and $hiera_hash are taken.
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

class cron

(
$jobs = undef,
$defaults = {ensure => enabled, user => root},
$hiera_hash = false,
)

{

  # Validate the parameters passed to the module to fail quickly rather than
  # passing create_resources invalid options

  validate_hash($jobs,$defaults)
  validate_bool($hiera_hash)

  # $cron_jobs is used as an interim as puppet does not allow us to
  # reassign variables

  if $hiera_hash == true {
    $cron_jobs = hiera_hash('cron::jobs')
  }
  else {
    $cron_jobs = $jobs
  }

  create_resources(cron, $cron_jobs, $defaults)

}

