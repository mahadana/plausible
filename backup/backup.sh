#!/bin/bash

set -eu
cd "$(dirname "$0")"
cd ..

docker-compose-backup() {
  docker-compose -f docker-compose.yml -f backup/docker-compose-backup.yml "$@"
}

mkdir -p backup/data

docker-compose stop plausible

docker-compose stop clickhouse
docker-compose-backup run --rm clickhouse bash -c \
  'tar cz /var/lib/clickhouse > /backup/data/clickhouse.tar.gz'
docker-compose rm -f clickhouse
docker-compose up -d clickhouse

docker-compose stop postgres
docker-compose-backup up -d postgres
docker-compose-backup exec postgres bash -c \
  'pg_dump -U plausible plausible > /backup/data/postgres.sql'
docker-compose-backup stop postgres
docker-compose rm -f postgres
docker-compose up -d postgres

docker-compose up -d plausible
