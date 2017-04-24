FROM openjdk:8u121-jre-alpine

MAINTAINER Régis Belson <regis@evaneos.com>

RUN apk add --no-cache --virtual .runDeps \
    curl \
    git \
    openssh-client \
    pwgen \
    sudo \
    util-linux

ENV RDECK_BASE=/opt/rundeck
ENV RDECK_JAR=$RDECK_BASE/app.jar
ENV RUNDECK_VERSION=2.8.2

RUN mkdir -p $RDECK_BASE \
    && curl -L -o $RDECK_JAR http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-$RUNDECK_VERSION.jar

EXPOSE 4440

ENTRYPOINT java -jar ${RDECK_BASE}/app.jar
