#!/bin/bash
# https://github.com/aws/amazon-ecs-agent
set -eo pipefail

export DEBIAN_FRONTEND=noninteractive 

cloud-init status --wait

# Install Docker
set +e
apt remove docker docker-engine docker.io containerd runc
set -e
apt update
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu
systemctl enable docker

# Create ECS folders 
mkdir -p /var/log/ecs /etc/ecs /var/lib/ecs/data
touch /etc/ecs/ecs.config

# Set up necessary rules to enable IAM roles for tasks
sysctl -w net.ipv4.conf.all.route_localnet=1
iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
