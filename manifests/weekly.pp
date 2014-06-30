# This class takes parameters for the file type and wraps them with the
# create_resources function to allow creation of N number of cron jobs under
# /etc/cron.weekly/
#
# The parameters $jobs, $defaults, $hiera_hash, and $purge are taken.
#
# $jobs should be a nested hash of cron jobs where the name of the job is the
# index and contents key is given to provide the file. This is used as the
# underlying method for this is using the puppet file type wrapped in
# create_resources. This is intended for simple one line scripts.
#
# $defaults should also be a hash of the puppet file type attributes. If values
# are specified in both $defaults and $jobs the value in $jobs takes precedence.
#
# Files can also be provided under the puppet:///modules/cron/weekly/ directory
# for more lengthy scripts.
#
# $hiera_hash is a boolean, if true it enables lookup of values in all level of
# the hierarchy. This allows you to define a set of common cron jobs at a low
# level and node or group specific jobs at a higher level. The default hiera
# behaviour would only match the first entry in the 'closest' hierarchy.
#
# $purge affects the /etc/cron.d/weekly/ directory as a whole, by default this
# is disabled. If enabled only cron jobs in puppet will be permitted on the
# system.

class cron::weekly

(
$jobs = undef,
$defaults = { user  => 'root',
              group => 'root',
              mode  => '0755',
              require => File['/etc/cron.weekly'],
            },
$hiera_hash = false,
$purge = false,
)

{

  # Validate the parameters passed to the module to fail quickly rather than
  # passing create_resources invalid options.
  # Not checking $jobs as it may be hash or undef.

  validate_hash($defaults)
  validate_bool($hiera_hash, $purge)

  # $cron_jobs is used as an interim as puppet does not allow us to
  # reassign variables.

  if $hiera_hash == true {
    $cron_jobs = hiera_hash('cron::weekly::jobs')
  }
  else {
    $cron_jobs = $jobs
  }

  # Sync any files provided in the files directory of this module.

  file { '/etc/cron.weekly':
    ensure  => directory,
    source  => 'puppet:///modules/cron/weekly/',
    user    => 'root',
    group   => 'root',
    purge   => $purge,
    recurse => true,
    force   => true,
  }

  # Create one liners or simple jobs passed as parameters
  # Placing within if as $jobs may never be passed a value in which case we
  # should take no action.

  if is_hash($jobs) == true {
    create_resources(file, $cron_job, $defaults)
  }
  elsif $jobs != undef {
    fail ('\$jobs was expected to be a hash or undef')
  }

}
