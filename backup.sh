#!/bin/bash
echo "[\`date +"%d-%b-%Y %T"\`] Backing up ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}..."
/usr/bin/mysqldump --host ${DATABASE_HOST} --port ${DATABASE_PORT} -u ${DATABASE_USER} -p${DATABASE_PASSWORD} -y ${DATABASE_NAME} > /tmp/backup_${DATABASE_NAME}_latest.sql
cd /tmp; zip backup_${DATABASE_NAME}_latest.sql.zip backup_${DATABASE_NAME}_latest.sql; cd /
cp /tmp/backup_${DATABASE_NAME}_latest.sql.zip /tmp/backup_${DATABASE_NAME}_\`date +"%Y%m%d"\`.sql.zip
echo "[\`date +"%d-%b-%Y %T"\`] Copying to Telegram chat: ${CHAT_ID}..."
./upload_to_telegram.sh /tmp/backup_${DATABASE_NAME}_latest.sql.zip
rm -rf /tmp/*.sql*
echo "[\`date +"%d-%b-%Y %T"\`] Backed and copied up!"