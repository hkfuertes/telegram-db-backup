#!/bin/bash
set -e

DATE=$(date +"%Y%m%d")
TIME=$(date +"%d-%b-%Y %T")

DATABASE_TYPE=${DATABASE_TYPE:-mysql}
BACKUP_NAME=${DATABASE_NAME:-backup}
BACKUP_FILE=${BACKUP_FILE:-/tmp/backup_${BACKUP_NAME}_latest.sql}

if [ -n "${BACKUP_COMMAND}" ]; then
    echo "[${TIME}] Running custom backup command..."
    sh -c "${BACKUP_COMMAND}"
    if [ -n "${BACKUP_FILE_COMMAND}" ]; then
        BACKUP_FILE=$(sh -c "${BACKUP_FILE_COMMAND}")
    fi
    if [ -z "${BACKUP_FILE}" ] || [ ! -f "${BACKUP_FILE}" ]; then
        echo "[${TIME}] ERROR: backup file not found: ${BACKUP_FILE}"
        exit 1
    fi
    echo "[${TIME}] Custom backup file: ${BACKUP_FILE}"
    UPLOAD_FILE="${BACKUP_FILE}"
else
    echo "[${TIME}] Backing up ${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME} (${DATABASE_TYPE})..."

    case "${DATABASE_TYPE}" in
        mysql)
            /usr/bin/mysqldump --host "${DATABASE_HOST}" --port "${DATABASE_PORT}" \
                -u "${DATABASE_USER}" -p"${DATABASE_PASSWORD}" \
                -y "${DATABASE_NAME}" > "${BACKUP_FILE}"
            ;;
        postgres)
            export PGPASSWORD="${DATABASE_PASSWORD}"
            /usr/bin/pg_dump -h "${DATABASE_HOST}" -p "${DATABASE_PORT}" \
                -U "${DATABASE_USER}" \
                "${DATABASE_NAME}" > "${BACKUP_FILE}"
            unset PGPASSWORD
            ;;
        *)
            echo "[${TIME}] ERROR: Unsupported DATABASE_TYPE '${DATABASE_TYPE}'. Use 'mysql' or 'postgres'."
            exit 1
            ;;
    esac

    UPLOAD_FILE="/tmp/${BACKUP_NAME}_${DATE}.sql.zip"
    zip -j "${UPLOAD_FILE}" "${BACKUP_FILE}"
fi

echo "[${TIME}] Copying to Telegram chat: ${CHAT_ID}..."
sh /scripts/upload_to_telegram.sh "${UPLOAD_FILE}"
rm -f /tmp/backup_${BACKUP_NAME}_latest.sql /tmp/${BACKUP_NAME}_${DATE}.sql.zip
echo "[${TIME}] Backed and copied up!"
