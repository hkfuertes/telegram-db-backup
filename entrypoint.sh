#!/bin/bash

# Creating the upload script
cat <<EOF >> /upload_to_telegram.sh
#! /bin/bash
# Usage: $ ./upload_to_telegram.sh <file_path>
# TELEGRAM_TOKEN & CHAT_ID env variables must exist!

if [ -e LAST_MESSAGE ]
then
    LAST_MESSAGE=\`cat LAST_MESSAGE\`
    # Remove previous upload if LAST_MESSAGE exists
    curl -s "https://api.telegram.org/bot\${TELEGRAM_TOKEN}/deleteMessage?chat_id=\${CHAT_ID}&message_id=\${LAST_MESSAGE}" -o /dev/null
fi

# Run the upload
curl -s -F document=@"\$1" "https://api.telegram.org/bot\${TELEGRAM_TOKEN}/sendDocument?chat_id=\${CHAT_ID}" | jq '.result.message_id' > LAST_MESSAGE
EOF

# Creating the backup script
cat <<EOF >> /backup.sh
#!/bin/bash

DATE=\`date +"%d.%m.%Y"\`
TIME=\`date +"%d-%b-%Y %T"\`

echo "[\${TIME}] Backing up \${DATABASE_HOST}:\${DATABASE_PORT}/\${DATABASE_NAME}..."
/usr/bin/mysqldump --host \${DATABASE_HOST} --port \${DATABASE_PORT} -u \${DATABASE_USER} -p\${DATABASE_PASSWORD} -y \${DATABASE_NAME} > /tmp/backup_\${DATABASE_NAME}_latest.sql
cd /tmp; zip backup_\${DATABASE_NAME}_\${DATE}.sql.zip backup_\${DATABASE_NAME}_latest.sql; cd /
echo "[\${TIME}] Copying to Telegram chat: \${CHAT_ID}..."
/upload_to_telegram.sh /tmp/backup_\${DATABASE_NAME}_\${DATE}.sql.zip
rm -rf /tmp/*.sql*
echo "[\${TIME}] Backed and copied up!"
EOF

# Creating the CRON file.
cat <<EOF > /var/spool/cron/crontabs/root
${CRON_EXPRESION} /bin/bash /backup.sh >> /var/log/cron.log 2>&1

EOF

# Setting permissions and running
chmod 0644 /var/spool/cron/crontabs/root
touch /var/log/cron.log

echo "[`date +"%d-%b-%Y %T"`] Starting CRON: ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} -> Telegram/${CHAT_ID}"
crond && tail -f /var/log/cron.log
