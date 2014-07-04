# This is the cron::service class, it ensures cron is running.

class cron::service

{

  # Attempt to work out the cron service name, default to cron as this seems to
  # be the most common.

  case $::osfamily {
    'RedHat': { $cron_service = 'crond' }
    'Debain': { $cron_service = 'cron' }
    'Suse':   { $cron_service = 'cron' }
    default:  { $cron_service = 'cron' }
  }

  service { $cron_service :
    ensure  => running,
    enable  => true,
  }

}

