#!/bin/bash

# Creating the CRON file.
cat <<EOF > /var/spool/cron/crontabs/root
${CRON_EXPRESION} /bin/bash /backup.sh >> /var/log/cron.log 2>&1

EOF

# Setting permissions and running
chmod 0644 /var/spool/cron/crontabs/root
touch /var/log/cron.log

echo "[`date +"%d-%b-%Y %T"`] Starting CRON: ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} -> Telegram/${CHAT_ID}"
crond && tail -f /var/log/cron.log
