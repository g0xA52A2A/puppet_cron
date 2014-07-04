# This is the main cron class.
#
# $hiera_hash is taken as a parameter which if set to true will cause hiera to
# lookup values for all hierachies for cron jobs passed as parameters.

class cron

(
$hiera_hash = false,
$purge = false,
)

{

  validate_bool($hiera_hash, $purge)

  include cron::service
  include cron::crontab
  include cron::hourly
  include cron::daily
  include cron::weekly
  include cron::monthly

}

