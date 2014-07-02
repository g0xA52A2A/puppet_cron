# This class takes parameters for the file type and wraps them with the
# create_resources function to allow creation of N number of cron jobs under
# /etc/cron.monthly/
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
# Files can also be provided under the puppet:///modules/cron/monthly/ directory
# for more lengthy scripts.
#
# $hiera_hash is a boolean, if true it enables lookup of values in all level of
# the hierarchy. This allows you to define a set of common cron jobs at a low
# level and node or group specific jobs at a higher level. The default hiera
# behaviour would only match the first entry in the 'closest' hierarchy.
#
# $purge affects the /etc/cron.d/monthly/ directory as a whole, by default this
# is disabled. If enabled only cron jobs in puppet will be permitted on the
# system.

class cron::monthly

(
$jobs = undef,
$hiera_hash = false,
$purge = false,
)

{

  # Validate the parameters passed to the module to fail quickly rather than
  # passing create_resources invalid options.
  # Not checking $jobs as it may be hash or undef.

  validate_bool($hiera_hash, $purge)

  # $cron_jobs is used as an interim as puppet does not allow us to
  # reassign variables.

  if $hiera_hash == true {
    $cron_jobs = hiera_hash('cron::monthly::jobs')
  }
  elsif $cron::hiera_hash == true {
    $cron_jobs = hiera_hash('cron::monthly::jobs')
  }
  else {
    $cron_jobs = $jobs
  }

  # Sync any files provided in the files directory of this module.

  file { '/etc/cron.monthly':
    ensure  => directory,
    source  => 'puppet:///modules/cron/monthly/',
    owner   => 'root',
    group   => 'root',
    purge   => $purge,
    recurse => true,
    force   => true,
  }

  # Create one liners or simple jobs passed as parameters
  # Placing within if as $jobs may never be passed a value in which case we
  # should take no action.

  if is_hash($cron_jobs) == true {

    # Need to use future parser here as referncing with $name when merged from
    # other locations in the manifest would return the class 'cron::monthly' as
    # namevar as well as numerous other issues.

    each($cron_jobs) | $index, $value | {
      file { "/etc/cron.monthly/${index}":
        ensure  => present,
        content => "${value[command]}\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/etc/cron.monthly'],
      }
    }
  }
  elsif $cron_jobs != undef {
    $type = type($cron_jobs)
    fail ("\$jobs was expected hash or undef, got ${cron_jobs} type:${type}")
  }

}

