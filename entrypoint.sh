#!/bin/bash

# Creating the backup script
cat <<EOF >> /backup.sh
#!/bin/bash
echo "[\`date +"%d-%b-%Y %T"\`] Backing up ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}..."
/usr/bin/mysqldump --host ${DATABASE_HOST} --port ${DATABASE_PORT} -u ${DATABASE_USER} -p${DATABASE_PASSWORD} -y ${DATABASE_NAME} > /tmp/backup_${DATABASE_NAME}_latest.sql
cd /tmp; zip backup_${DATABASE_NAME}_latest.sql.zip backup_${DATABASE_NAME}_latest.sql; cd /
cp /tmp/backup_${DATABASE_NAME}_latest.sql.zip /tmp/backup_${DATABASE_NAME}_\`date +"%Y%m%d"\`.sql.zip
echo "[\`date +"%d-%b-%Y %T"\`] Copying to ${REMOTE_SERVICE}:${REMOTE_FOLDER}..."
/usr/bin/rclone copy /tmp/ ${REMOTE_SERVICE}:${REMOTE_FOLDER} --include "*.sql.zip"
rm -rf /tmp/*.sql*
/usr/bin/rclone delete ${REMOTE_SERVICE}:${REMOTE_FOLDER} --include "*.sql.zip" --min-age ${REMOTE_KEEP_TIME} 
echo "[\`date +"%d-%b-%Y %T"\`] Backed and copied up!"
EOF

# Creating the CRON file.
cat <<EOF > /var/spool/cron/crontabs/root
${CRON_EXPRESION} /bin/bash /backup.sh >> /var/log/cron.log 2>&1

EOF

# Setting permissions and running
chmod 0644 /var/spool/cron/crontabs/root
touch /var/log/cron.log

echo "[`date +"%d-%b-%Y %T"`] Starting CRON: ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} -> ${REMOTE_SERVICE}:${REMOTE_FOLDER}"
crond && tail -f /var/log/cron.log
