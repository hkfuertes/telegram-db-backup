## Telegram Database Backup
Simple docker image to `cron` a database backup to a Telegram Bot. Supports **MySQL** and **PostgreSQL**.

### Image

```
ghcr.io/hkfuertes/telegram-db-backup:master
```

The image includes `mysql-client`, `postgresql-client`, and `docker-cli`. Use `DATABASE_TYPE` to select the built-in dump command.

### Environment variables

| Variable | Example Value | Description |
|--------- | ------------- | ----------- |
| DATABASE_TYPE | mysql | `mysql` or `postgres` |
| DATABASE_NAME | csbookdb | Name of the database. |
| DATABASE_USER | admin | Database user to be used. |
| DATABASE_PASSWORD | **** | Database user's password. |
| DATABASE_HOST | localhost | Database url. |
| DATABASE_PORT | 3306 | Database port. |
| CRON_EXPRESION | * * * * * | CRON expresion for the backup to happen. |
| TELEGRAM_TOKEN | ******** | Telegram token from `BotFather` |
| CHAT_ID | **** | Chat ID to where the backup will be sent. |
| BACKUP_COMMAND | docker exec app mix backup /backups | Optional command override. If set, this command creates the file to upload. |
| BACKUP_FILE | /backups/latest.sql.zip | File uploaded after `BACKUP_COMMAND`. Defaults to `/tmp/backup_${DATABASE_NAME}_latest.sql`. |
| BACKUP_FILE_COMMAND | ls -t /backups/*.sql.zip \| head -n1 | Optional command run after `BACKUP_COMMAND`; its stdout becomes the file to upload. Takes precedence over `BACKUP_FILE`. |

### Integration with existing project

Add a `docker-compose.override.yml` file:
```yaml
services:
  telegrambot:
    image: ghcr.io/hkfuertes/telegram-db-backup:master
    environment:
      - DATABASE_TYPE=${DATABASE_TYPE}
      - DATABASE_USER=${DATABASE_USER}
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_NAME=${DATABASE_NAME}
      - DATABASE_HOST=${DATABASE_HOST}
      - DATABASE_PORT=${DATABASE_PORT}
      - TELEGRAM_TOKEN=${TELEGRAM_TOKEN}
      - CHAT_ID=${CHAT_ID}
      - CRON_EXPRESION=${CRON_EXPRESION}
    restart: unless-stopped
```

> Provided that you added the required variables in the `.env` file, by running `docker compose up` on your project, `docker compose` will pick both `docker-compose.yml` and `docker-compose.override.yml` files and so, both projects will be on the same network and no ports need to be exported.

### Custom backup command

If your app already has a backup task, use `BACKUP_COMMAND`. The command must create `BACKUP_FILE`; that file is uploaded as-is.

If the backup task creates dynamic filenames, set `BACKUP_FILE_COMMAND`. It runs after `BACKUP_COMMAND`; its stdout becomes the file uploaded.

Example using another container through the Docker socket:

```yaml
services:
  telegrambot:
    image: ghcr.io/hkfuertes/telegram-db-backup:master
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./backups:/backups
    environment:
      BACKUP_COMMAND: docker exec doceacordes-backend manage backup /backups
      BACKUP_FILE_COMMAND: "ls -t /backups/doceacordes_*.sql.zip | head -n1"
      TELEGRAM_TOKEN: ${TELEGRAM_TOKEN}
      CHAT_ID: ${CHAT_ID}
      CRON_EXPRESION: ${CRON_EXPRESION}
```

Warning: mounting `/var/run/docker.sock` gives this container Docker control over the host.
