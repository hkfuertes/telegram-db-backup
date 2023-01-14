## Rclone Database Backup
Simple docker image to `cron` a database backup to a popular cloud service.

### Configure
First you need to setup your remotes, to do so you need to install `rclone` and run `rclone config`

```bash
sudo -v ; curl https://rclone.org/install.sh | sudo bash
rclone config
```

This will produce a file called `~/.config/rclone/rclone.conf` similar to this:

```conf
[nextcloud]
type = webdav
url = <some_url>
vendor = nextcloud
user = <some_user>
pass = <some_password>
```
> To just execute `docker-compose up` with the provided docker compose file, you need to copy that `rclone.conf` file to the root of this repo.

### Run
You can run it via docker-compose, but there are several environment variables that need to be passed on:

| Variable | Example Value | Description |
|--------- | ------------- | ----------- |
| DATABASE_NAME | csbookdb | Name of the database. |
| DATABASE_USER | admin | Database user to be used. |
| DATABASE_PASSWORD | **** | Database user's password. |
| DATABASE_HOST | localhost | Database url. |
| DATABASE_PORT | 3306 | Database port. |
| REMOTE_SERVICE | nextcloud | Service to be used from the `rclone.conf` file. (ex. _[nextcloud]_) |
| REMOTE_FOLDER | csbookdb/ | Folder inside the remote. |
| CRON_EXPRESION | * * * * * | CRON expresion for the backup to happen. |
| REMOTE_KEEP_TIME | 5d | Retention days to keep backups. |

To run it:

```shell
cp .env.dist .env
nano .env # ... and edit all the variables
cp ~/.config/rclone/rclone.conf .
docker-compose up -d
```

### Integration with existing project
To integrate into an existing project you can just first build the project:
```bash
docker build -t rclone-db-backup .
```
...and add the following `docker-compose.override.yml` file:
```yaml
version: '3.5'

services:
  rclone:
    image: rclone-db-backup:latest # or the <tag> you specified on build...
    environment:
      - DATABASE_USER=${DATABASE_USER}
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_NAME=${DATABASE_NAME}
      - DATABASE_HOST=${DATABASE_HOST}
      - DATABASE_PORT=${DATABASE_PORT}
      - REMOTE_SERVICE=${REMOTE_SERVICE}
      - REMOTE_FOLDER=${REMOTE_FOLDER}
      - CRON_EXPRESION=${CRON_EXPRESION}
      - REMOTE_KEEP_TIME=${REMOTE_KEEP_TIME:-5d}
    volumes:
      - /root/.config/rclone:/root/.config/rclone # path to the rcloned file
    restart: unless-stopped
```
Provided that you added the required variables in the `.env` file, by running `docker-compose up` on your project, `docker-compose` will pick both `docker-compose.yml` and `docker-compose.override.yml` files and so, both project will be on the same network and no ports need to be exported.
