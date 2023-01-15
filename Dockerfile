FROM alpine
LABEL author="Miguel Fuertes <hkfuertes@gmail.com>"

# Changing Timezone
RUN apk add tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN echo "Europe/Madrid" >  /etc/timezone

# Installing dependencies
RUN apk add unzip curl bash zip jq

# Install mysql-client
RUN apk add --no-cache mysql-client

# Copying file
COPY entrypoint.sh /entrypoint.sh

# Setting up permissions
RUN chmod +x /entrypoint.sh

#ENTRYPOINT ["crond", "-f"]
ENTRYPOINT ["/entrypoint.sh"]