# Ghost Blog Auto-Deployment

Auto-deployment setup for Ghost blog using GitHub Actions, Docker, Nginx, and MariaDB on Debian server.

## Features

- Automated deployment on push to main branch
- Docker-based Ghost installation
- Nginx reverse proxy with SSL (Let's Encrypt)
- MariaDB database
- GitHub Actions workflow

## Prerequisites

- Debian server with sudo access
- Domain name pointed to your server
- GitHub account

## Setup Instructions

### 1. Server Initial Setup

SSH into your server and run the setup script:

```bash
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts/setup-server.sh
chmod +x setup-server.sh
./setup-server.sh
```

### 2. GitHub Repository Setup

1. Fork or clone this repository
2. Go to Settings → Secrets and variables → Actions
3. Add the following secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| SSH_HOST | Your server's IP or domain | 192.168.1.100 |
| SSH_USER | SSH username | ubuntu |
| SSH_KEY | Private SSH key (base64 encoded) | See below |
| DOMAIN | Your blog domain | blog.example.com |
| DB_PASSWORD | MariaDB password | strong-password |
| ADMIN_EMAIL | Email for SSL certificates | admin@example.com |

#### How to encode SSH key:
```bash
cat ~/.ssh/id_rsa | base64 -w 0
```

### 3. Deploy

Push to the main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

## Project Structure

```
ghost-blog/
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions workflow
├── docker-compose.yml      # Docker configuration
├── nginx/
│   └── ghost.conf         # Nginx configuration
├── scripts/
│   ├── setup-server.sh    # Server setup script
│   └── deploy.sh          # Local deployment script
├── content/               # Ghost content (gitignored)
├── .env.example           # Environment variables template
└── README.md
```

## Manual Deployment

For manual deployment, SSH into your server:

```bash
cd ~/ghost-blog
./scripts/deploy.sh
```

## Troubleshooting

### Check logs
```bash
docker-compose logs -f ghost
```

### Restart services
```bash
docker-compose restart
sudo systemctl restart nginx
```

### Database connection issues
Ensure MariaDB is running and credentials in `.env` match database setup.

## Security Notes

- Keep `.env` file secure and never commit it
- Use strong passwords for database
- Regularly update server packages
- Monitor server logs for suspicious activity

## License

MIT