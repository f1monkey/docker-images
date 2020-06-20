#!/bin/bash
{
  composer install
  test -f /srv/bin/rr || /srv/vendor/bin/rr get-binary --location /srv/bin
  if [ ${DEV_MODE} == 1 ]; then
    echo "Starting dev server"
    /srv/bin/rr -v -d -c /srv/.rr.dev.yaml serve
  else
    echo "Starting prod server"
    /srv/bin/rr -v -c /srv/.rr.yaml serve
  fi
} || {
  echo $1 && tail -f /dev/null
}
