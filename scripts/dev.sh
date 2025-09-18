#!/bin/bash

# FoodyBuddy Local Development Script

set -e

echo "🍕 Starting FoodyBuddy Microservices locally..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start services with Docker Compose
echo "Starting services with Docker Compose..."
docker-compose up --build

echo "✅ All services are running!"
echo ""
echo "Services available at:"
echo "Frontend: http://localhost:3000"
echo "Gateway: http://localhost:8080"
echo "Orders: http://localhost:8081"
echo "Payments: http://localhost:8082"
echo ""
echo "Press Ctrl+C to stop all services"
