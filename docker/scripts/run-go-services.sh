#!/bin/bash
# =============================================================================
# QUCKAPP - GO SERVICES RUNNER
# =============================================================================
# Run Go services for different environments
# Usage: ./run-go-services.sh [environment] [action]
# Examples:
#   ./run-go-services.sh local up
#   ./run-go-services.sh dev build
#   ./run-go-services.sh production down
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
ENVIRONMENT="${1:-local}"
ACTION="${2:-up}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}QUCKAPP - GO SERVICES${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Action: ${YELLOW}$ACTION${NC}"
echo ""

# Determine compose files based on environment
BASE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.yml"

case "$ENVIRONMENT" in
  local)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.local.yml"
    ENV_FILE="$DOCKER_DIR/.env.local"
    ;;
  dev|development)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.dev.yml"
    ENV_FILE="$DOCKER_DIR/.env.dev"
    ;;
  qa)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.qa.yml"
    ENV_FILE="$DOCKER_DIR/.env.qa"
    ;;
  uat1)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.uat.yml"
    ENV_FILE="$DOCKER_DIR/.env.uat1"
    ;;
  uat2)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.uat.yml"
    ENV_FILE="$DOCKER_DIR/.env.uat2"
    ;;
  uat3)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.uat.yml"
    ENV_FILE="$DOCKER_DIR/.env.uat3"
    ;;
  staging)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.staging.yml"
    ENV_FILE="$DOCKER_DIR/.env.staging"
    ;;
  production|prod)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.production.yml"
    ENV_FILE="$DOCKER_DIR/.env.production"
    ;;
  live)
    OVERRIDE_COMPOSE="$DOCKER_DIR/docker-compose.go-services.live.yml"
    ENV_FILE="$DOCKER_DIR/.env.live"
    ;;
  *)
    echo -e "${RED}Unknown environment: $ENVIRONMENT${NC}"
    echo "Available environments: local, dev, qa, uat1, uat2, uat3, staging, production, live"
    exit 1
    ;;
esac

# Check if files exist
if [ ! -f "$BASE_COMPOSE" ]; then
  echo -e "${RED}Base compose file not found: $BASE_COMPOSE${NC}"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo -e "${YELLOW}Warning: Environment file not found: $ENV_FILE${NC}"
  echo "Creating from example..."
  if [ -f "$DOCKER_DIR/.env.example" ]; then
    cp "$DOCKER_DIR/.env.example" "$ENV_FILE"
  fi
fi

# Build compose command
COMPOSE_CMD="docker-compose -f $BASE_COMPOSE"
if [ -f "$OVERRIDE_COMPOSE" ]; then
  COMPOSE_CMD="$COMPOSE_CMD -f $OVERRIDE_COMPOSE"
fi
COMPOSE_CMD="$COMPOSE_CMD --env-file $ENV_FILE"

# Execute action
case "$ACTION" in
  up)
    echo -e "${GREEN}Starting Go services...${NC}"
    $COMPOSE_CMD up -d
    echo -e "${GREEN}Services started successfully!${NC}"
    $COMPOSE_CMD ps
    ;;
  up-build)
    echo -e "${GREEN}Building and starting Go services...${NC}"
    $COMPOSE_CMD up -d --build
    echo -e "${GREEN}Services started successfully!${NC}"
    $COMPOSE_CMD ps
    ;;
  down)
    echo -e "${YELLOW}Stopping Go services...${NC}"
    $COMPOSE_CMD down
    echo -e "${GREEN}Services stopped.${NC}"
    ;;
  restart)
    echo -e "${YELLOW}Restarting Go services...${NC}"
    $COMPOSE_CMD restart
    echo -e "${GREEN}Services restarted.${NC}"
    ;;
  build)
    echo -e "${GREEN}Building Go services...${NC}"
    $COMPOSE_CMD build
    echo -e "${GREEN}Build complete.${NC}"
    ;;
  logs)
    $COMPOSE_CMD logs -f
    ;;
  ps|status)
    $COMPOSE_CMD ps
    ;;
  pull)
    echo -e "${GREEN}Pulling latest images...${NC}"
    $COMPOSE_CMD pull
    ;;
  *)
    echo -e "${RED}Unknown action: $ACTION${NC}"
    echo "Available actions: up, up-build, down, restart, build, logs, ps, status, pull"
    exit 1
    ;;
esac
