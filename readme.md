## Telegram Database Backup
Simple docker image to `cron` a database backup to a popular Telegram Bot.


### Run
You can run it via docker-compose, but there are several environment variables that need to be passed on:

| Variable | Example Value | Description |
|--------- | ------------- | ----------- |
| DATABASE_NAME | csbookdb | Name of the database. |
| DATABASE_USER | admin | Database user to be used. |
| DATABASE_PASSWORD | **** | Database user's password. |
| DATABASE_HOST | localhost | Database url. |
| DATABASE_PORT | 3306 | Database port. |
| CRON_EXPRESION | * * * * * | CRON expresion for the backup to happen. |
| TELEGRAM_TOKEN | ******** | Telegram token from `BotFather` |
| CHAT_ID | **** | Chat ID to where the backup will be sent. |

To run it:

```shell
cp .env.dist .env
nano .env # ... and edit all the variables
docker-compose up -d
```

### Integration with existing project
To integrate into an existing project you can just first build the project:
```bash
docker build -t telegram-db-backup .
```
...and add the following `docker-compose.override.yml` file:
```yaml
version: '3.5'

services:
  rclone:
    image: telegram-db-backup:latest # or the <tag> you specified on build...
    environment:
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
Provided that you added the required variables in the `.env` file, by running `docker-compose up` on your project, `docker-compose` will pick both `docker-compose.yml` and `docker-compose.override.yml` files and so, both project will be on the same network and no ports need to be exported.
