#!/bin/bash

# Get the local IP address (cross-platform approach)
if command -v ifconfig >/dev/null 2>&1; then
    # macOS/Linux with ifconfig
    HOST_IP=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
elif command -v ip >/dev/null 2>&1; then
    # Linux with ip command
    HOST_IP=$(ip route get 1 | awk '{print $7; exit}')
elif command -v hostname >/dev/null 2>&1; then
    # Fallback using hostname
    HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || hostname -i | awk '{print $1}' 2>/dev/null)
else
    echo "Warning: Could not determine host IP address. Using localhost."
    HOST_IP="localhost"
fi

# Remove any trailing whitespace
HOST_IP=$(echo "$HOST_IP" | tr -d '[:space:]')

if [ -z "$HOST_IP" ]; then
    echo "Warning: Could not determine host IP address. Using localhost."
    HOST_IP="localhost"
fi

echo "Using HOST_IP: $HOST_IP"

# Build Docker images
echo "Building backend Docker image..."
docker build -t studentbackend --build-arg HOST_IP="$HOST_IP" -f ./backend/Dockerfile ./backend

echo "Building frontend Docker image..."
docker build -t studentfrontend --build-arg HOST_IP="$HOST_IP" -f ./frontend/Dockerfile ./frontend

# Start services with docker-compose
echo "Starting services with docker-compose..."
docker-compose -f docker-compose.yml up -d

# Open the application in default browser (cross-platform)
echo "Opening application in browser..."
if command -v open >/dev/null 2>&1; then
    # macOS
    open http://localhost:80
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open http://localhost:80
elif command -v start >/dev/null 2>&1; then
    # Windows (Git Bash, etc.)
    start http://localhost:80
else
    echo "Please open http://localhost:80 in your browser"
fi
