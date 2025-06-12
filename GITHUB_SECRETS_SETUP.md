# GitHub Secrets Setup Guide

## Required GitHub Secrets

### 1. SSH_HOST
- **Description**: Your server's IP address or domain
- **Example**: `123.456.789.0` or `server.example.com`
- **How to get**: Use your server's public IP address

### 2. SSH_USER
- **Description**: SSH username for your server
- **Example**: `ubuntu`, `root`, `admin`
- **How to get**: The username you use to SSH into your server

### 3. SSH_KEY
- **Description**: Base64 encoded private SSH key
- **How to create**:
  ```bash
  # For existing key:
  cat ~/.ssh/id_rsa | base64 -w 0
  
  # For AWS/Lightsail key:
  cat your-key.pem | base64 -w 0
  
  # To create new key pair:
  ssh-keygen -t rsa -b 4096 -f ghost_deploy_key -N ""
  cat ghost_deploy_key | base64 -w 0
  # Add ghost_deploy_key.pub to server's ~/.ssh/authorized_keys
  ```

### 4. DOMAIN
- **Description**: Your blog's domain name (without https://)
- **Example**: `blog.example.com`
- **Note**: Must have DNS A record pointing to your server

### 5. DB_PASSWORD
- **Description**: Strong password for MariaDB database
- **Example**: `SuperSecure123!@#`
- **Requirements**: At least 12 characters, mix of letters, numbers, symbols

### 6. DB_HOST
- **Description**: Database host address
- **Value**: `host.docker.internal` (for macOS/Windows) or `172.17.0.1` (for Linux)
- **Note**: This allows Docker container to connect to host's MariaDB

### 7. ADMIN_EMAIL
- **Description**: Email for Let's Encrypt SSL certificates
- **Example**: `admin@example.com`
- **Note**: Will receive SSL renewal notifications

### 8. MAIL_FROM (Optional)
- **Description**: From address for emails  
- **Example**: `noreply@blog.example.com`
- **Note**: Used with Direct mail transport (no external service needed)

## How to Add Secrets to GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the exact name listed above
5. Paste the value and click **Add secret**

## Verification Checklist

- [ ] SSH_HOST is correct server IP/domain
- [ ] SSH_USER matches server login username
- [ ] SSH_KEY is base64 encoded and authorized on server
- [ ] DOMAIN has DNS pointing to server
- [ ] DB_PASSWORD is strong and memorable
- [ ] DB_HOST is set correctly for your OS
- [ ] ADMIN_EMAIL is valid and monitored
- [ ] Email settings are from verified Mailgun domain (if using)