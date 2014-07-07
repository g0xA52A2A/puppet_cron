# The parameters $jobs, $intervals, $hiera_hash, and $purge are taken.
#
# $jobs should be a nested hash of cron jobs where the name of the job is the
# index and contents and interval keys are given. The contents is simply the
# contents for the file that will be created and interval should be one of the
# values passed to the $intervals parameter
#
# $intervals is an array of the names of periodic cron execution. The defaults
# should work for nearly all systems, but can be overridden.
#
# Files can also be provided under the puppet:///modules/cron/daily/ directory
# for more lengthy scripts.
#
# $hiera_hash is a boolean, if true it enables lookup of values in all level of
# the hierarchy. This allows you to define a set of common cron jobs at a low
# level and node or group specific jobs at a higher level. The default hiera
# behaviour would only match the first entry in the 'closest' hierarchy.
#
# $purge affects the /etc/cron.${intervals} directories as a whole, by default
# this is disabled. If enabled only cron jobs in puppet will be permitted on the
# system. It takes a boolean.

class cron::interval

(
$jobs = undef,
$intervals = [ 'hourly', 'daily', 'weekly', 'monthly' ],
$hiera_hash = false,
$purge = false,
)

{

  # Validate the parameters passed to the module to fail quickly rather than
  # passing create_resources invalid options.
  # Not checking $jobs as it may be hash or undef.

  validate_bool($hiera_hash, $purge)
  validate_array($intervals)

  # $cron_jobs is used as an interim as puppet does not allow us to
  # reassign variables.

  if $cron::hiera_hash == true {
    $cron_jobs = hiera_hash('cron::interval::jobs')
  }
  elsif $hiera_hash == true {
    $cron_jobs = hiera_hash('cron::interval::jobs')
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

  # Sync any files provided in the files directory of this module.
  # Placed within defined type due to namevar referencing.

  define cron_intervals {
    file { $name :
      path    => "/etc/cron.${name}",
      ensure  => directory,
      source  => "puppet:///modules/cron/${name}/",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      purge   => $cron::interval::cron_purge,
      recurse => true,
      force   => true,
    }
  }

  cron_intervals { $intervals : }

  # Create one liners or simple jobs passed as parameters
  # Placing within if as $jobs may never be passed a value in which case we
  # should take no action.

  if is_hash($cron_jobs) == true {

    # Need to use future parser here as referencing with $name when merged from
    # other locations in the manifest would return the class name as namevar in
    # addition to numerous other issues.

    each($cron_jobs) | $index, $value | {

      # Fail if we dont get an contents or interval for the cron job.

      if $value[command] == undef {
        fail ("${index} did not provide a value for command")
      }
      if $value[interval] == undef {
        fail ("${index} did not provide a value for interval")
      }

      file { "/etc/cron.${value[interval]}/${index}":
        ensure  => present,
        content => "${value[command]}\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File[$intervals],
      }
    }
  }
  elsif $cron_jobs != undef {
    $type = type($cron_jobs)
    fail ("\$jobs was expected hash or undef, got ${cron_jobs} type:${type}")
  }

}

