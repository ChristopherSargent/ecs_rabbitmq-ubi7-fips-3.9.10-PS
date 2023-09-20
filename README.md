![alt text](ecs.logo.JPG)
# Build base images needed to create the rabbitmq-fips:latest container image
This repository contains the necessary source code files to build the following container images.. For additional details, please email at [c.sargent-ctr@ecstech.com](mailto:c.sargent-ctr@ecstech.com).

1. ub7:1
2. ub7-1-base-rabbitmq:1
3. rabbitmq-ubi7-fips:3.9.10

# Build ECS ub7:1 from [ironbank-repo](https://repo1.dso.mil/dsop/redhat/ubi/ubi7).
* Note that I used the ironbank repo but added 2 scripts. 
* One is to properly enable FIPS and the second is to install RHEL repo provided maintenance/troubleshooting utilities and add time stamps to the bash history and terminal (see content under comments in Dockerfile labeled "CAS tools" for these commands.
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cd /home/christopher.sargent/automation_helper_scripts/rabbitmq/rabbitmq3.11.6-ubi8-fips/base/ubi8
4. vim Dockerfile
```

```
5. docker build -t ub7:1 -f Dockerfile .
6. docker run -it ub7:1 /bin/bash
7. fips-mode-setup --check
```
FIPS mode is enabled.
```
# Build ECS ub7-1-base-rabbitmq:1
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cas 
4. cd /home/christopher.sargent/automation_helper_scripts/rabbitmq/rabbitmq3.11.6-ubi8-fips/rabbitmq-dockerfiles/rabbitmq-base
5. vim Dockerfile
```

```
10. docker build -t ub8-1-base-rabbitmq:1 -f Dockerfile .
9. docker run -it ub8-1-base-rabbitmq:1 /bin/bash
10. fips-mode-setup --check
```
FIPS mode is enabled.
```
# Build ECS rabbitmq-ubi8-fips:3.9.10
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. cd /home/christopher.sargent/automation_helper_scripts/rabbitmq/rabbitmq3.11.6-ubi8-fips/rabbitmq-dockerfiles/rabbitmq-fips3.11.6
4. vim Dockerfile
```

```
5. DOCKER_BUILDKIT=1 docker build -t rabbitmq-ubi8-fips:3.11.6 -f Dockerfile .
6. docker run -it -u:0 rabbitmq-ubi8-fips:3.11.6 /bin/bash
7. ll /plugins/ | wc -l # Note this now matches 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:latest
```
75
```
8. rabbitmqadmin --version
```
rabbitmqadmin 3.11.6
```

# Tag and push to PG ECR
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i
3. su - jdonaldson
4. aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com
5. docker tag rabbitmq-ubi8-fips:3.11.6 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.11.6.25.2.3.0.9
6. docker push 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.11.6.25.2.3.0.9

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
# Docker save rabbitmq-fips:3.11.6.25.2.3.0.9
1. ssh -i /root/ecs/alpha_key_pair.pem ec2-user@PG-TerraformPublicIP
2. sudo -i 
3. docker save -o /home/ec2-user/images/rabbitmq-fips:3.11.6.25.2.3.0.9.tar 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.11.6.25.2.3.0.9
4. ll /mnt/s3/images
```
total 11098808
-rw-------. 1 root root 2908504064 Jul 11 14:34 rabbitmq-fips3.11.6-6.0_agency07102023.tar
-rw-------. 1 root root 2908488192 Jul 11 13:51 rabbitmq-fips3.11.6-6.0_central07102023.tar
-rw-------. 1 root root 2908503552 Jul 11 14:53 rabbitmq-fips3.11.6-6.0_federal07102023.tar
-rw-------. 1 root root 2639683072 Jul 10 15:59 rabbitmq-fips:3.11.6.25.2.3.0.9.tar
```



