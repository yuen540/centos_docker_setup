#!/bin/bash
#Update Centos to latest packages
sudo yum -y update
#Installing Docker dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
#Add docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#Installing docker
sudo yum install docker-ce
#Adding current user to group
sudo usermod -aG docker $(whoami)
#Setting Docker to boot at start time
sudo systemctl enable docker.service
#Starting docker service
sudo systemctl start docker.service