FROM openjdk:8u121-jre-alpine

MAINTAINER Régis Belson <regis@evaneos.com>

RUN apk add --no-cache --virtual .runDeps \
    bash \
    curl \
    git \
    knock \
    openssh-client \
    pwgen \
    sudo \
    su-exec \
    util-linux

ENV RDECK_BASE=/opt/rundeck
ENV RDECK_JAR=$RDECK_BASE/app.jar
ENV RUNDECK_VERSION=2.8.3

RUN mkdir -p $RDECK_BASE \
    && curl -L -o $RDECK_JAR http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-$RUNDECK_VERSION.jar \
    && java -jar ${RDECK_BASE}/app.jar --installonly

EXPOSE 4440

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD java -jar ${RDECK_BASE}/app.jar --skipinstall
