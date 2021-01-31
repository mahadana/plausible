#!/bin/bash

[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -eu
cd "$(dirname "$0")/.."

PUJAS_LIVE_DIR="/opt/pujas.live"
LOG_DIR="$PUJAS_LIVE_DIR/logs/deploy/$(date +%Y/%m)"
LOG_FILE="plausible-$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

(
  echo "$(date) start $0"

  git fetch
  git reset --hard origin/main

  docker-compose pull
  docker-compose up -d -t 3
  docker image prune -f

  echo "$(date) end $0"

) 2>&1 | tee -a "$LOG_DIR/$LOG_FILE"
