#!/bin/bash

[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -eu
SCRIPT_PATH="$(realpath "$0")"
cd "$(dirname "$0")/.."

PUJAS_LIVE_DIR="/opt/pujas.live"

LOG_NAME="plausible-deploy"
LOG_DIR="$PUJAS_LIVE_DIR/logs/deploy"
LOG_FILE="$LOG_NAME-$(date +%Y-%m-%d).log"
LOG_PATH="$LOG_DIR/$LOG_FILE"
LATEST_PATH="$LOG_DIR/latest-$LOG_NAME.log"

test -x /usr/bin/ts || apt-get install -yqq moreutils

mkdir -p "$LOG_DIR"
ln -sf "$LOG_FILE" "$LATEST_PATH"

(
  echo "$SCRIPT_PATH START"

  git fetch
  git reset --hard origin/main

  docker-compose pull -q
  docker-compose up -d -t 3
  docker image prune -f

  git log -1

  echo "$SCRIPT_PATH END"

) 2>&1 | ts "[%Y-%m-%d %H:%M:%S]" | tee -a "$LOG_PATH"

ls -rt1 "$LOG_DIR/$LOG_NAME-"*.log | head -n -10 | xargs --no-run-if-empty rm
