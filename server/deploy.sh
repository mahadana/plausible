#!/bin/bash

[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -eu

log="/var/log/plausible-deploy.log"

(
  echo "$(date) start $0"

  cd /opt/plausible
  git fetch
  git reset --hard origin/main

  docker-compose pull
  docker-compose up -d -t 3
  docker image prune -f

  echo "$(date) end $0"

) 2>&1 | tee -a "$log"
