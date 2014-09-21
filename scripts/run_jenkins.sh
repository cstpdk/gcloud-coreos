#!/bin/bash

mkdir -p /mnt/pd0
/usr/share/google/safe_format_and_mount -m "mkfs.ext4 -F" /dev/sdb /mnt/pd0/
mkdir /mnt/pd0/docker
sed -i.bak -r 's|^DOCKER_OPTS=.*|DOCKER_OPTS="-g /mnt/pd0/docker"|g' /etc/default/docker

docker run -e GCS_BUCKET=quniz-registry -d --name registry \
	-p 5000:5000 google/docker-registry

docker run -p 80:8080 -v /root/jenkins:/root/.jenkins \
	--link registry:registry --privileged \
	michaelneale/jenkins-docker-executors
