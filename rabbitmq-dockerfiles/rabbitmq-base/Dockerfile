FROM ub7:1

# Install dependencies
RUN yum -y install \
    tar \
    wget \
    procps \
    logrotate \
    unzip \
    wget \
    make \
    git \
    socat 

# Copy RPMS
COPY openssl-libs-1.0.2k-19.el7.x86_64.rpm /tmp
COPY openssl-1.0.2k-19.el7.x86_64.rpm /tmp
COPY erlang-23.2-1.el7_9.x86_64.rpm /tmp
COPY rabbitmq-server-3.9.10-1.el7.noarch.rpm /tmp

# Install RPMS
RUN yum downgrade --nogpgcheck -y /tmp/openssl-libs-1.0.2k-19.el7.x86_64.rpm
RUN yum install --nogpgcheck -y /tmp/openssl-1.0.2k-19.el7.x86_64.rpm
RUN rpm -i /tmp/erlang-23.2-1.el7_9.x86_64.rpm
RUN rpm -i /tmp/rabbitmq-server-3.9.10-1.el7.noarch.rpm

# Install the rest of openssl
RUN yum -y install \
    openssl-devel-1.0.2k-26.el7_9.x86_64 \
    pyOpenSSL-0.13.1-4.el7.x86_64

# Expose the RabbitMQ ports
EXPOSE 5672 15672

# Set the default command to run when the container starts
CMD ["rabbitmq-server"]
