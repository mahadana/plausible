# Pujas.live Analytics

[Plausible Analytics](https://github.com/plausible/analytics) for
[Pujas.live](https://pujas.live/).

## Server Setup

```sh
git clone https://github.com/mahadana/plausible.git /opt/plausible
cd /opt/plausible
cp .env.example .env

# Edit .env

docker-compose up -d
```

## Backup/Restore

```sh
backup/backup.sh

# Files will be in backup/data

backup/restore.sh
```
