# Image
FROM ub7-1-base-rabbitmq:1
USER root

# Rabbitmq Version
ARG APP_VERSION=3.9.10

ARG APP_VERSION

# Set ENV
ENV HOME="/var/lib/rabbitmq" \
    LANG="C.UTF-8" \
    LANGUAGE="C.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    RABBITMQ_HOME="/opt/rabbitmq" \
    RABBITMQ_VERSION="${APP_VERSION}" \
    RABBITMQ_DATA_DIR="/var/lib/rabbitmq" \
    RABBITMQ_LOGS="-" \
    RABBITMQ_USER="rabbitmq" \
    RABBITMQ_GROUP="rabbitmq" \
    PATH="${RABBITMQ_HOME}/sbin:$PATH" 

# Copy
COPY docker-entrypoint.sh /usr/local/bin/
COPY datetime2.sh /tmp/datetime2.sh 
RUN chmod +x /tmp/datetime2.sh

# Create rabbitmq system user & group, fix permissions & allow root user to connect to the RabbitMQ Erlang VM
RUN mkdir -p /opt/rabbitmq /etc/rabbitmq /etc/rabbitmq/conf.d /var/log/rabbitmq /tmp/rabbitmq-ssl && \
    chown rabbitmq:0 -R ${HOME} ${RABBITMQ_HOME} /etc/rabbitmq /var/log/rabbitmq /tmp/rabbitmq-ssl && \
    chmod g=u -R ${HOME} ${RABBITMQ_HOME} /etc/rabbitmq /var/log/rabbitmq /tmp/rabbitmq-ssl && \
    ln -s ${RABBITMQ_DATA_DIR} ${RABBITMQ_HOME}/var && \
    ln -s ${RABBITMQ_HOME}/plugins /plugins && \
    yum update -y && \
    yum install -y hostname && \
    yum clean all && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    # CCE finding fix
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq /etc/rabbitmq/conf.d /tmp/rabbitmq-ssl /var/log/rabbitmq && \
    chmod 700 /var/lib/rabbitmq /etc/rabbitmq /etc/rabbitmq/conf.d /tmp/rabbitmq-ssl /var/log/rabbitmq && \
    rm -f /var/lib/rabbitmq/.erlang.cookie

# Fix prompt 
RUN /tmp/datetime2.sh

# Fix rabbitmqadmin
RUN yum -y install rh-python36 && \
    cp /usr/lib/rabbitmq/lib/rabbitmq_server-3.9.10/plugins/rabbitmq_management-3.9.10/priv/www/cli/rabbitmqadmin /usr/local/bin/rabbitmqadmin && chmod 755 /usr/local/bin/rabbitmqadmin

# Fix prompt for rabbitmq user
RUN set -eux; \
    cp /root/.bashrc /var/lib/rabbitmq; \
    chown rabbitmq:rabbitmq /var/lib/rabbitmq/.bashrc

# Set user back back as this is how the original Dockerfile was
WORKDIR ${RABBITMQ_HOME}

VOLUME ${RABBITMQ_DATA_DIR}

USER rabbitmq

# MANAGEMENT-TLS MANAGEMENT
EXPOSE 15671 15672
# PROMETHEUS-TLS PROMETHEUS
EXPOSE 15691 15692
# STREAM-TLS STREAM
EXPOSE 5551 5552
# MQTT-TLS MQTT
EXPOSE 8883 1883
# WEB-MQTT-TLS WEB-MQTT
EXPOSE 15676 15675
# STOMP-TLS STOMP
EXPOSE 61614 61613
# WEB-STOMP-TLS WEB-STOMP
EXPOSE 15673 15674
# EXAMPLES
EXPOSE 15670
# EPMD AMQP-TLS AMQP ERLANG
EXPOSE 4369 5671 5672 25672


ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["rabbitmq-server"]
