#!/bin/bash
# Update system packages
apt-get update

# Install Docker
apt-get install -y docker.io

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Run Minecraft server in Docker
docker run -d \
  --name minecraft \
  -p ${minecraft_port}:25565 \
  -e EULA=TRUE \
  -e MEMORY=2G \
  --restart always \
  itzg/minecraft-server:latest