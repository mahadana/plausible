#!/bin/bash

set -eu
cd "$(dirname "$0")"
cd ..

docker-compose-backup() {
  docker-compose -f docker-compose.yml -f backup/docker-compose-backup.yml "$@"
}

if ! test -f backup/data/clickhouse.tar.gz; then
  echo "backup/data/clickhouse.tar.gz does not exist"
  exit 1
fi

if ! test -f backup/data/postgres.sql; then
  echo "backup/data/postgres.sql does not exist"
  exit 1
fi

docker-compose stop plausible

docker-compose stop clickhouse
docker-compose-backup run --rm clickhouse bash -c '
  rm -rf /var/lib/clickhouse/* &&
  cd / &&
  tar zxf /backup/data/clickhouse.tar.gz'
docker-compose rm -f clickhouse
docker-compose up -d clickhouse

docker-compose stop postgres
docker-compose-backup up -d postgres
docker-compose-backup exec postgres bash -c '
  echo "DROP DATABASE IF EXISTS plausible" | psql -U plausible -d postgres &&
  echo "CREATE DATABASE plausible" | psql -U plausible -d postgres &&
  psql --quiet -f /backup/data/postgres.sql -U plausible -d plausible'
docker-compose-backup stop postgres
docker-compose rm -f postgres
docker-compose up -d postgres

docker-compose up -d plausible
