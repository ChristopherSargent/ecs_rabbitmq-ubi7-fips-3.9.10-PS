FROM ub8:1

# Install dependencies
RUN dnf -y update && dnf -y install \
    openssl-devel \
    tar \
    gcc \
    perl \
    ncurses-devel \
    wget \
    procps \
    logrotate \
    unzip \
    autoconf \
    m4 \
    openssl \
    wget \
    make \
    git \
    socat \
    less 

# Download and build Erlang 25.2 with FIPS 140-2 compliant cryptography
RUN wget https://github.com/erlang/otp/archive/OTP-25.2.tar.gz
RUN tar xvzf OTP-25.2.tar.gz
WORKDIR otp-OTP-25.2
RUN ./otp_build configure --with-ssl --enable-fips
RUN make
RUN make install

# Download and install RabbitMQ 3.11
WORKDIR /
RUN wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.11.6/rabbitmq-server-3.11.6-1.el8.noarch.rpm
RUN rpm -ivh --nodeps rabbitmq-server-3.11.6-1.el8.noarch.rpm

# Set environment variables
ENV PATH /opt/rabbitmq/sbin:$PATH

# Expose the RabbitMQ ports
EXPOSE 5672 15672

# Set the default command to run when the container starts
CMD ["rabbitmq-server"]
