#!/bin/bash

DATE=$(date +"%Y%m%d")
TIME=$(date +"%d-%b-%Y %T")

DATABASE_TYPE=${DATABASE_TYPE:-mysql}

echo "[${TIME}] Backing up ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} (${DATABASE_TYPE})..."

case "${DATABASE_TYPE}" in
    mysql)
        /usr/bin/mysqldump --host ${DATABASE_HOST} --port ${DATABASE_PORT} \
            -u ${DATABASE_USER} -p${DATABASE_PASSWORD} \
            -y ${DATABASE_NAME} > /tmp/backup_${DATABASE_NAME}_latest.sql
        ;;
    postgres)
        export PGPASSWORD="${DATABASE_PASSWORD}"
        /usr/bin/pg_dump -h ${DATABASE_HOST} -p ${DATABASE_PORT} \
            -U ${DATABASE_USER} \
            ${DATABASE_NAME} > /tmp/backup_${DATABASE_NAME}_latest.sql
        unset PGPASSWORD
        ;;
    *)
        echo "[${TIME}] ERROR: Unsupported DATABASE_TYPE '${DATABASE_TYPE}'. Use 'mysql' or 'postgres'."
        exit 1
        ;;
esac

cd /tmp; zip ${DATABASE_NAME}_${DATE}.sql.zip backup_${DATABASE_NAME}_latest.sql; cd /
echo "[${TIME}] Copying to Telegram chat: ${CHAT_ID}..."
sh /scripts/upload_to_telegram.sh /tmp/${DATABASE_NAME}_${DATE}.sql.zip
rm -rf /tmp/*.sql*
echo "[${TIME}] Backed and copied up!"
