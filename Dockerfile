FROM alpine
LABEL author="Miguel Fuertes <hkfuertes@gmail.com>"

# Timezone
RUN apk add --no-cache tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime \
    && echo "Europe/Madrid" > /etc/timezone

# Dependencies + DB clients
RUN apk add --no-cache curl bash zip unzip jq mysql-client postgresql-client

# Copy scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
