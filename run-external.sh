#!/bin/bash

# Script to run OpenHands with frontend exposed on 0.0.0.0 using Docker containers
# This allows external access to OpenHands on configurable ports

# Set colors for output
GREEN=$(tput -Txterm setaf 2)
YELLOW=$(tput -Txterm setaf 3)
RED=$(tput -Txterm setaf 1)
BLUE=$(tput -Txterm setaf 6)
RESET=$(tput -Txterm sgr0)

# Configuration - default ports
OPENHANDS_PORT="${OPENHANDS_PORT:-3000}"
WORKSPACE_BASE="${WORKSPACE_BASE:-$(pwd)/workspace}"

echo "${YELLOW}Starting OpenHands with external access using Docker...${RESET}"
echo "${BLUE}OpenHands will be accessible at: http://0.0.0.0:${OPENHANDS_PORT}${RESET}"
echo "${BLUE}Workspace directory: ${WORKSPACE_BASE}${RESET}"
echo ""

# Check if running inside Docker
if [ -f /.dockerenv ]; then
    echo "${RED}Already running inside a Docker container. Exiting...${RESET}"
    exit 1
fi

# Check if Docker is available
if ! command -v docker > /dev/null; then
    echo "${RED}Docker is not installed. Please install Docker to continue.${RESET}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose > /dev/null && ! docker compose version > /dev/null 2>&1; then
    echo "${RED}Docker Compose is not available. Please install Docker Compose to continue.${RESET}"
    exit 1
fi

# Create workspace directory if it doesn't exist
mkdir -p "${WORKSPACE_BASE}"

# Set environment variables for Docker Compose
export WORKSPACE_BASE="${WORKSPACE_BASE}"
export SANDBOX_USER_ID=$(id -u)
export DATE=$(date +%Y%m%d%H%M%S)

# Function to cleanup on exit
cleanup() {
    echo "${YELLOW}Shutting down OpenHands containers...${RESET}"
    if command -v docker-compose > /dev/null; then
        docker-compose down
    else
        docker compose down
    fi
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM EXIT

# Create a temporary docker-compose override for custom port mapping
cat > docker-compose.override.yml << EOF
services:
  openhands:
    ports:
      - "${OPENHANDS_PORT}:3000"
EOF

echo "${YELLOW}Building and starting OpenHands container...${RESET}"
echo "${BLUE}This may take a few minutes on first run...${RESET}"

# Start the containers
if command -v docker-compose > /dev/null; then
    docker-compose up --build
else
    docker compose up --build
fi

echo "${YELLOW}OpenHands is now running on port ${OPENHANDS_PORT}.${RESET}"
echo "${BLUE}You can access it at: http://0.0.0.0:${OPENHANDS_PORT}${RESET}"
echo "${BLUE}Workspace directory: ${WORKSPACE_BASE}${RESET}"
echo "${BLUE}Press Ctrl+C to stop the containers.${RESET}"
echo "${BLUE}The model information is located https://docs.google.com/spreadsheets/d/1wOUdFCMyY6Nt0AIqF705KN4JKOWgeI4wUGUP60krXXs/edit?gid=0#gid=0${RESET}"
echo ""
