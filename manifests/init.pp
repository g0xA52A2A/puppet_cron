# This is the cron class, it ensures cron is running.
#
# Pass $cron_service the name of your cron daemon if it is not named crond and
# you are not on a Debain based system. Please file an issue or pull request if
# you have to do this.

class cron

(
$hiera_hash = false,
)

{

  validate_bool($hiera_hash)

  # Attempt to work out the cron service name, default to crond.

  case $::osfamily {
    'RedHat': { $cron_service = 'crond' }
    'Debain': { $cron_service = 'cron' }
    default:  { $cron_service = 'crond' }
  }

  service { $cron_service :
    ensure  => running,
    enable  => true,
  }

}

