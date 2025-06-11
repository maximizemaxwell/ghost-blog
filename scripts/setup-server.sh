#!/bin/bash

set -e

echo "Setting up server for Ghost blog deployment..."

# Update system
sudo apt update
sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y \
    docker.io \
    docker-compose \
    nginx \
    mariadb-server \
    certbot \
    python3-certbot-nginx \
    git \
    curl

# Enable and start services
sudo systemctl enable docker nginx mariadb
sudo systemctl start docker nginx mariadb

# Add current user to docker group
sudo usermod -aG docker $USER

# Setup MariaDB for Ghost
echo "Setting up MariaDB..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ghost_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'ghost-user'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD:-changeme}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ghost_db.* TO 'ghost-user'@'127.0.0.1';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create ghost directories
mkdir -p ~/ghost-blog/content
cd ~/ghost-blog

# Setup firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 2368/tcp
sudo ufw --force enable

echo "Server setup complete!"
echo "Next steps:"
echo "1. Set up GitHub secrets in your repository"
echo "2. Push your code to trigger deployment"
echo "3. The workflow will handle nginx config and SSL setup"
