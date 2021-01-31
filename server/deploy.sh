#!/bin/bash

[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -eu
cd "$(dirname "$0")/.."

PUJAS_LIVE_DIR="/opt/pujas.live"
LOG_DIR="$PUJAS_LIVE_DIR/logs/deploy/$(date +%Y/%m)"
LOG_FILE="plausible-deploy-$(date +%Y-%m-%d).log"

test -x /usr/bin/ts || apt-get install -yqq moreutils

mkdir -p "$LOG_DIR"

(
  echo "$(realpath "$0") START"

  git fetch
  git reset --hard origin/main

  docker-compose pull -q
  docker-compose up -d -t 3
  docker image prune -f

  echo "$(realpath "$0") END"

) 2>&1 | ts | tee -a "$LOG_DIR/$LOG_FILE"
