![alt text](ecs.logo.JPG)
# Build base images needed to create the rabbitmq-fips:latest container image
This repository contains the necessary source code files to build the following container images.. For additional details, please email at [c.sargent-ctr@ecstech.com](mailto:c.sargent-ctr@ecstech.com).

1. ub7:1
2. ub7-1-base-rabbitmq:1
3. rabbitmq-ubi7-fips:3.9.10

# Build ECS ub7:1 image from [ironbank-repo](https://repo1.dso.mil/dsop/redhat/ubi/ubi7).
* Note that I used the ironbank repo but added 2 scripts. 
* One is to properly enable FIPS and the second is to install RHEL repo provided maintenance/troubleshooting utilities and add time stamps to the bash history and terminal (see content under comments in Dockerfile labeled "CAS tools" for these commands.
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cd cd /home/christopher.sargent/ecs_rabbitmq-ubi7-fips-3.9.10-PS/rabbitmq-dockerfiles/ubi7
4. vim Dockerfile
```
# Utilize the image from download.yaml
# This is because we need to download the latest image from Red Hat. Current
# implementation for doing ARG based FROM instructions require replacing
# the FROM with an already existing image (i.e. one we've previously built).
# This prevents us from retrieving the latest image from Red Hat.
FROM registry.access.redhat.com/ubi7/ubi:7.9

COPY scripts/*.sh /dsop-fix/

COPY yum.repos.d/ /etc/yum.repos.d

COPY banner/issue /etc/

RUN echo Update packages and install DISA STIG fixes && \
    echo "exclude=redhat-release-server" >> /etc/yum.conf && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-* && \
    # Disable all repositories (to limit RHEL host repositories) and only use official UBI repositories
    sed -i "s/enabled=1/enabled=0/" /etc/yum/pluginconf.d/subscription-manager.conf && \
    rm -f /etc/yum.repos.d/ubi.repo && \
    yum repolist && \
    yum update -y && \
    chmod +x /dsop-fix/*.sh && \
    # Do not use loops to iterate through shell dsop-fix, this allows for dsop-fix to fail
    # but the build to still be successful. Be explicit when executing dsop-fix and ensure
    # that all dsop-fix have "set -e" at the top of the bash file!
    /dsop-fix/xccdf_org.ssgproject.content_rule_account_disable_post_pw_expiration.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_logon_fail_delay.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_difok.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_lcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxclassrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_minclass.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_minlen.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ucredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_unix_remember.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_set_max_life_existing.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_set_min_life_existing.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny_root.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_interval.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_tmout.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_clean_components_post_updating.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_ensure_gpgcheck_local_packages.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_libreswan_approved_tunnels.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_no_empty_passwords.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_rpm_verify_permissions.sh && \
    yum clean all && \
    rm -rf /var/cache/yum/ /var/tmp/* /tmp/* /var/tmp/.???* /tmp/.???*

# CAS tools, install vi, vim and less to make the image more useful
RUN yum install -y \
    vim \
    less

# #  CAS tools 2, add datetime.sh adds a time stampt to bash history and the terminal and creates a bash alias for ll.
RUN yum update -y && \
    /dsop-fix/datetime.sh

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Purposely not setting USER as this is a builder image 
CMD ["/bin/bash"]
```
5. docker build -t ub7:1 -f Dockerfile .
6. docker run -it ub7:1 /bin/bash
7. cat /proc/sys/crypto/fips_enabled
* Show FIPS enabled
``
1
``
# Build ECS ub7-1-base-rabbitmq:1 image
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cas 
4. cd /home/christopher.sargent/ecs_rabbitmq-ubi7-fips-3.9.10-PS/rabbitmq-dockerfiles/rabbitmq-base
5. vim Dockerfile
```
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
```
6. docker build -t ub7-1-base-rabbitmq:1 -f Dockerfile .
7. docker run -it ub7-1-base-rabbitmq:1 /bin/bash
8. cat /proc/sys/crypto/fips_enabled
* Show FIPS enabled
``
1
`` 
# Build ECS rabbitmq-ubi7-fips:3.9.10 image
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cd /home/christopher.sargent/ecs_rabbitmq-ubi7-fips-3.9.10-PS/rabbitmq-dockerfiles/rabbitmq-fips3.9.10
4. vim Dockerfile
```
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
```
5. DOCKER_BUILDKIT=1 docker build -t rabbitmq-ubi7-fips:3.9.10 -f Dockerfile .
6. docker run -it -u:0 rabbitmq-ubi7-fips:3.9.10 /bin/bash

# Tag and push to PG ECR
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i
3. su - jdonaldson
4. aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com
5. docker tag rabbitmq-ubi7-fips:3.9.10 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.9.10.23.2.1.1.0.2
6. docker push 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.9.10.23.2.1.1.0.2

# S3 Fuse PG-Terraform 
* Created s3fs#s3fusedocker S3 Bucket in Playground
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel hdparm -y
4. cd /root
5. git clone https://github.com/s3fs-fuse/s3fs-fuse.git
6. cd s3fs-fuse
7. ./autogen.sh
8. ./configure --prefix=/usr --with-openssl
9. make
10. make install
11. which s3fs
```
/bin/s3fs
```
12. echo 'AWS_ACCESS_KEY_ID:AWS_SECRET_ACCESS_KEY' >> /etc/passwd-s3fs && chmod 640 /etc/passwd-s3fs #Note this terraform_service_user account and is stored in Secrets Manger 
13. mkdir /mnt/s3
14. s3fs s3fusedocker /mnt/s3 -o passwd_file=/etc/passwd-s3fs -o url=https://s3-us-gov-west-1.amazonaws.com
15. ll /mnt/s3/images
```
total 2577816
-rw-------. 1 root root 2639683072 Jul 10 15:59 rabbitmq-fips:3.11.6.25.2.3.0.9.tar
```
16. umount /mnt/s3
17.cp /etc/fstab /etc/fstab.07102023 && echo 's3fs#s3fusedocker /mnt/s3 fuse allow_other,_netdev,nosuid,nodev,url=https://s3-us-gov-west-1.amazonaws.com 0 0' >> /etc/fstab

18. mount -av
```
/                        : ignored
/var                     : already mounted
/var/log/audit           : already mounted
/tmp                     : already mounted
/home                    : already mounted
/dev/shm                 : already mounted
/mnt/s3                  : successfully mounted
```
19. ll /mnt/s3/images/
```
total 2577816
-rw-------. 1 root root 2639683072 Jul 10 15:59 rabbitmq-fips:3.11.6.25.2.3.0.9.tar
```
# Docker save rabbitmq-fips:3.9.10.23.2.1.1.0.2
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i
3. docker save -o /mnt/s3/images/rabbitmq-fips:3.9.10.23.2.1.1.0.2.tar 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.9.10.23.2.1.1.0.2
4. ll /mnt/s3/images
```
total 14334590
-rw-------. 1 root root 2908504064 Jul 11 14:34 rabbitmq-fips3.11.6-6.0_agency07102023.tar
-rw-------. 1 root root 2908488192 Jul 11 13:51 rabbitmq-fips3.11.6-6.0_central07102023.tar
-rw-------. 1 root root 2908503552 Jul 11 14:53 rabbitmq-fips3.11.6-6.0_federal07102023.tar
-rw-------. 1 root root 2656096256 Sep 13 17:41 rabbitmq-fips:3.11.6.25.2.2.3.0.9.tar
-rw-------. 1 root root 2639683072 Jul 10 15:59 rabbitmq-fips:3.11.6.25.2.3.0.9.tar
-rw-------. 1 root root  657345024 Sep 20 19:19 rabbitmq-fips:3.9.10.23.2.1.1.0.2.tar
```


