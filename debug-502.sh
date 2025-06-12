#!/bin/bash

# Debugging script for Ghost 502 errors
set -e

echo "=== Ghost Blog 502 Error Debugging ==="
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo "Create .env file from .env.example"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

echo "1. Checking environment variables..."
echo "   DOMAIN: ${DOMAIN}"
echo "   URL: ${URL}"
echo "   DB_HOST: ${DB_HOST}"
echo "   DB_PASSWORD: [HIDDEN]"
echo

echo "2. Checking Docker containers..."
docker compose ps
echo

echo "3. Checking Ghost container health..."
if docker compose ps | grep -q "ghost.*Up.*healthy"; then
    echo -e "   Ghost container: ${GREEN}Healthy${NC}"
else
    echo -e "   Ghost container: ${RED}Unhealthy${NC}"
    echo "   Ghost logs:"
    docker compose logs --tail=20 ghost
fi
echo

echo "4. Testing Ghost HTTP endpoint..."
if curl -f -s http://localhost:2368 > /dev/null; then
    echo -e "   Ghost HTTP: ${GREEN}✓ Responding${NC}"
else
    echo -e "   Ghost HTTP: ${RED}✗ Not responding${NC}"
fi
echo

echo "5. Testing database connection from host..."
if command -v mysql &> /dev/null; then
    if mysql -h 127.0.0.1 -u ghost-user -p${DB_PASSWORD} -e "SELECT 1;" ghost_db &>/dev/null; then
        echo -e "   Database connection: ${GREEN}✓ Success${NC}"
    else
        echo -e "   Database connection: ${RED}✗ Failed${NC}"
        echo "   Check if MariaDB is running: sudo systemctl status mariadb"
    fi
else
    echo -e "   ${YELLOW}MySQL client not installed, skipping database test${NC}"
fi
echo

echo "6. Checking Nginx configuration..."
if [ -f /etc/nginx/sites-enabled/ghost ]; then
    echo "   Nginx config found at: /etc/nginx/sites-enabled/ghost"
    echo "   Server name: $(grep server_name /etc/nginx/sites-enabled/ghost | awk '{print $2}')"
    if sudo nginx -t &>/dev/null; then
        echo -e "   Nginx syntax: ${GREEN}✓ Valid${NC}"
    else
        echo -e "   Nginx syntax: ${RED}✗ Invalid${NC}"
        sudo nginx -t
    fi
else
    echo -e "   ${RED}Nginx config not found!${NC}"
fi
echo

echo "7. Common fixes for 502 errors:"
echo "   a) Database connection:"
echo "      - For Linux: DB_HOST=172.17.0.1"
echo "      - For Mac/Windows: DB_HOST=host.docker.internal"
echo "   b) Wait for Ghost to fully start (can take 60+ seconds)"
echo "   c) Check firewall allows port 2368"
echo "   d) Ensure MariaDB is running on host"
echo "   e) Check MariaDB user permissions"
echo

echo "8. Quick fix commands:"
echo "   # Restart everything"
echo "   docker compose down && docker compose up -d"
echo
echo "   # View live logs"
echo "   docker compose logs -f ghost"
echo
echo "   # Check MariaDB"
echo "   sudo systemctl status mariadb"
echo
echo "   # Test database connection"
echo "   mysql -h 127.0.0.1 -u ghost-user -p ghost_db"
