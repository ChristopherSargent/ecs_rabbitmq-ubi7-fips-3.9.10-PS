#!/bin/bash
# Christopher Sargent updated 09202023
set -x #echo on

# dos2unix files
dos2unix cert.pem chain.pem key.pem rabbitmq.conf advanced.config enabled_plugins

# Copy certs and rabbitmq.conf
docker cp cert.pem rabbitmq-fips3.9.10:/etc/rabbitmq/
docker cp chain.pem rabbitmq-fips3.9.10:/etc/rabbitmq/
docker cp key.pem rabbitmq-fips3.9.10:/etc/rabbitmq/
docker cp rabbitmq.conf rabbitmq-fips3.9.10:/etc/rabbitmq/ 
docker cp advanced.config rabbitmq-fips3.9.10:/etc/rabbitmq/
docker cp enabled_plugins rabbitmq-fips3.9.10:/etc/rabbitmq/

# Update permissions
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 cert.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 chain.pem 
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 rabbitmq.conf
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 advanced.config
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chmod 644 enabled_plugins

# Update ownerships
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq cert.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq chain.pem 
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq rabbitmq.conf
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq advanced.config
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.9.10 chown rabbitmq:rabbitmq enabled_plugins

# Restart container
docker restart rabbitmq-fips3.9.10

# Verify FIPS enabled in the kernel and openssl versions
docker exec -u:0 rabbitmq-fips3.9.10 cat /proc/cmdline
docker exec -u:0 rabbitmq-fips3.9.10 openssl version
