FROM alpine
LABEL author="Miguel Fuertes <hkfuertes@gmail.com>"

# Changing Timezone
RUN apk add tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN echo "Europe/Madrid" >  /etc/timezone

# Installing rclone
RUN apk add unzip curl bash zip jq
RUN curl https://rclone.org/install.sh | bash

# Install mysql-client
RUN apk add --no-cache mysql-client

# Entry point
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#ENTRYPOINT ["crond", "-f"]
ENTRYPOINT ["/entrypoint.sh"]