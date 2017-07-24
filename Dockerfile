FROM debian:stretch-slim

MAINTAINER Régis Belson <regis@evaneos.com>

# little hack so openjdk-8-jre-headless installation doesn't fail...
RUN mkdir -p /usr/share/man/man1/

RUN apt-get -qq update \
	&& apt-get install --no-install-recommends -qqy \
		curl \
		knockd \
		gosu \
		netcat \
		openjdk-8-jre-headless \
		openssh-client \
		pwgen \
		sudo \
		uuid-runtime

ENV DOCKER_VERSION 17.05.0

RUN set -ex \
	\
	&& curl -L "https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION-ce.tgz" \
	| tar -xz -C /usr/local/bin --strip-components=1 docker/docker \
  	&& chmod +x /usr/local/bin/docker

ENV TINI_VERSION 0.15.0
ENV TINI_SHA 4007655082f573603c02bc1d2137443c8e153af047ffd088d02ccc01e6f06170

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -


ENV RUNDECK_HOME /var/lib/rundeck

RUN mkdir "$RUNDECK_HOME"
RUN addgroup \
		--system \
		--gid 1000 \
		rundeck \
	&& adduser \
		--uid 1000 \
		--gid 1000 \
		--system \
		--no-create-home \
		--disabled-password \
		rundeck
RUN chown -R rundeck:rundeck "$RUNDECK_HOME"

ENV RUNDECK_VERSION 2.8.4

RUN curl -L -o rundeck.deb "http://dl.bintray.com/rundeck/rundeck-deb/rundeck-$RUNDECK_VERSION-1-GA.deb" \
	&& dpkg -i rundeck.deb \
	&& rm rundeck.deb \
	&& rm /etc/init.d/rundeckd

RUN mkdir -p /var/lib/rundeck/projects && chown rundeck:rundeck /var/lib/rundeck/projects

COPY rundeck.sh /usr/local/bin/rundeck
RUN chown rundeck:rundeck /usr/local/bin/rundeck
RUN chmod +x /usr/local/bin/rundeck

# Plugins

## EC2 nodes
ENV EC2_NODES_PLUGIN_VERSION 1.5.5
ENV EC2_NODES_PLUGIN_SHA 893f451296effb588c8ef20889969b547148ea86bb7406b7beb307cdc816f168

RUN curl -L -o /var/lib/rundeck/libext/rundeck-ec2-nodes-plugin-$EC2_NODES_PLUGIN_VERSION.jar "https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v$EC2_NODES_PLUGIN_VERSION/rundeck-ec2-nodes-plugin-$EC2_NODES_PLUGIN_VERSION.jar" \
	&& echo "$EC2_NODES_PLUGIN_SHA  /var/lib/rundeck/libext/rundeck-ec2-nodes-plugin-$EC2_NODES_PLUGIN_VERSION.jar" | sha256sum -c -

## Slack
ENV SLACK_PLUGIN_VERSION 0.6
ENV SLACK_PLUGIN_SHA d23b31ec4791dff1a7051f1f012725f20a1e3e9f85f64a874115e46df77e00b5

RUN curl -L -o /var/lib/rundeck/libext/rundeck-slack-incoming-webhook-plugin-$SLACK_PLUGIN_VERSION.jar "https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v$SLACK_PLUGIN_VERSION.dev/rundeck-slack-incoming-webhook-plugin-$SLACK_PLUGIN_VERSION.jar" \
	&& echo "$SLACK_PLUGIN_SHA  /var/lib/rundeck/libext/rundeck-slack-incoming-webhook-plugin-$SLACK_PLUGIN_VERSION.jar" | sha256sum -c -

## S3 Log
ENV S3_LOG_PLUGIN_VERSION 1.0.3
ENV S3_LOG_PLUGIN_SHA bf527c51188293e61c9b2492bfa699733d02842117371276f350681ccf941892
RUN curl -L -o /var/lib/rundeck/libext/rundeck-s3-log-plugin-$S3_LOG_PLUGIN_VERSION.jar "https://github.com/rundeck-plugins/rundeck-s3-log-plugin/releases/download/v$S3_LOG_PLUGIN_VERSION/rundeck-s3-log-plugin-$S3_LOG_PLUGIN_VERSION.jar" \
	&& echo "$S3_LOG_PLUGIN_SHA  /var/lib/rundeck/libext/rundeck-s3-log-plugin-$S3_LOG_PLUGIN_VERSION.jar" | sha256sum -c -

EXPOSE 4440

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rundeck"]