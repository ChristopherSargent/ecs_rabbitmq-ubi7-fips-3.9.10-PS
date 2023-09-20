from centos/systemd

RUN yum install -y make socat logrotate

COPY entrypoint.sh /tmp
RUN chmod +x /tmp/entrypoint.sh
COPY openssl-libs-1.0.2k-19.el7.x86_64.rpm /tmp
COPY openssl-1.0.2k-19.el7.x86_64.rpm /tmp
COPY erlang-23.1.4-1.el7.FIPS.rpm /tmp
COPY rabbitmq-server-3.8.5-1.el7.noarch.rpm /tmp

RUN rpm -U /tmp/openssl-libs-1.0.2k-19.el7.x86_64.rpm
RUN rpm -i /tmp/openssl-1.0.2k-19.el7.x86_64.rpm
RUN rpm -i /tmp/erlang-23.1.4-1.el7.FIPS.rpm
RUN rpm -i /tmp/rabbitmq-server-3.8.5-1.el7.noarch.rpm

EXPOSE 5672/tcp
EXPOSE 15672/tcp

ENTRYPOINT ["/tmp/entrypoint.sh"]
