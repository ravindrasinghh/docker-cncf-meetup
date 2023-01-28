#! /bin/bash -xe
yum update -y
sudo amazon-linux-extras disable docker
sudo amazon-linux-extras install -y ecs
sudo echo ECS_CLUSTER=docker-meetup-cluster >> /etc/ecs/ecs.config
systemctl enable --now --no-block ecs.service
