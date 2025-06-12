#!/bin/bash

# Local testing script for Ghost blog
set -e

echo "=== Ghost Blog Local Test ==="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if service is healthy
check_health() {
    local service=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -n "Checking $service health"
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s $url > /dev/null; then
            echo -e " ${GREEN}✓${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo -e " ${RED}✗${NC}"
    return 1
}

# Cleanup function
cleanup() {
    echo
    echo "Cleaning up test environment..."
    docker compose -f docker-compose.test.yml down -v
    rm -f .env
}

# Set trap for cleanup on exit
trap cleanup EXIT

echo "1. Setting up test environment..."
cp .env.test .env

echo "2. Stopping any existing containers..."
docker compose -f docker-compose.test.yml down -v 2>/dev/null || true

echo "3. Starting test containers..."
docker compose -f docker-compose.test.yml up -d

echo "4. Waiting for services to be ready..."
echo "   This may take up to 60 seconds..."

# Check database
if docker compose -f docker-compose.test.yml exec -T db mysqladmin ping -h localhost -u root -prootpassword123 &>/dev/null; then
    echo -e "   Database: ${GREEN}✓${NC}"
else
    echo -e "   Database: ${RED}✗${NC}"
    echo "   Database is not responding!"
    exit 1
fi

# Check Ghost
if check_health "Ghost" "http://localhost:2368"; then
    echo -e "   Ghost is running!"
else
    echo -e "   ${RED}Ghost failed to start!${NC}"
    echo
    echo "=== Ghost Container Logs ==="
    docker compose -f docker-compose.test.yml logs ghost
    exit 1
fi

echo
echo -e "${GREEN}=== Test Successful! ===${NC}"
echo
echo "Ghost is running at: http://localhost:2368"
echo "Admin panel: http://localhost:2368/ghost"
echo
echo "To view logs:"
echo "  docker compose -f docker-compose.test.yml logs -f"
echo
echo "To stop the test:"
echo "  docker compose -f docker-compose.test.yml down -v"
echo
echo "Press Ctrl+C to stop and cleanup..."

# Keep running until interrupted
while true; do
    sleep 1
done