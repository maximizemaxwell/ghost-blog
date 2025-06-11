#!/bin/bash

set -e

echo "Starting Ghost blog deployment..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check required variables
if [ -z "$DOMAIN" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: DOMAIN and DB_PASSWORD must be set in .env file"
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Update docker containers
echo "Updating Docker containers..."
docker-compose down
docker-compose pull
docker-compose up -d

# Wait for Ghost to start
echo "Waiting for Ghost to start..."
sleep 15

# Check if Ghost is running
if curl -f http://localhost:2368 > /dev/null 2>&1; then
    echo "Ghost is running successfully!"
else
    echo "Warning: Ghost might not be running properly"
fi

echo "Deployment complete!"
