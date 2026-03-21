## Telegram Database Backup
Simple docker image to `cron` a database backup to a Telegram Bot. Supports **MySQL** and **PostgreSQL**.

### Image

```
ghcr.io/hkfuertes/telegram-db-backup:master
```

The image includes both `mysql-client` and `postgresql-client`. Use `DATABASE_TYPE` to select which one to use.

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
