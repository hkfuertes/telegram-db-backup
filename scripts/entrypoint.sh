#!/bin/bash

# Creating the CRON file
cat <<EOF > /var/spool/cron/crontabs/root
${CRON_EXPRESION} /bin/bash /scripts/backup.sh >> /var/log/cron.log 2>&1

EOF

# Setting permissions and running
chmod 0644 /var/spool/cron/crontabs/root
touch /var/log/cron.log

BACKUP_NAME=${DATABASE_NAME:-backup}
BACKUP_FILE=${BACKUP_FILE:-/tmp/backup_${BACKUP_NAME}_latest.sql}

if [ -n "${BACKUP_COMMAND}" ]; then
    echo "[$(date +"%d-%b-%Y %T")] Starting CRON: custom backup -> ${BACKUP_FILE} -> Telegram/${CHAT_ID}"
else
    echo "[$(date +"%d-%b-%Y %T")] Starting CRON: ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} -> Telegram/${CHAT_ID}"
fi

crond && tail -f /var/log/cron.log
