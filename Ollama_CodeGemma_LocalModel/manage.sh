#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  manage.sh — Helper script for the CodeGemma Docker stack
#  Usage:
#    ./manage.sh start       Start all services
#    ./manage.sh stop        Stop all services
#    ./manage.sh restart     Restart all services
#    ./manage.sh logs        Tail logs from all containers
#    ./manage.sh status      Show container status
#    ./manage.sh pull-model  Pull/update the CodeGemma model
#    ./manage.sh reset       Stop + remove volumes (full reset)
# ─────────────────────────────────────────────────────────────

set -e

COMPOSE_FILE="$(dirname "$0")/docker-compose.yml"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cmd="${1:-help}"

case "$cmd" in
  start)
    echo -e "${GREEN}▶ Starting CodeGemma stack...${NC}"
    docker compose -f "$COMPOSE_FILE" up -d --remove-orphans
    echo ""
    echo -e "${GREEN}✔ Stack is up!${NC}"
    echo -e "  • Open WebUI  → ${YELLOW}http://localhost:3000${NC}"
    echo -e "  • Ollama API  → ${YELLOW}http://localhost:11434${NC}"
    echo ""
    echo -e "First run? The model is being pulled in the background."
    echo -e "Run ${YELLOW}./manage.sh logs${NC} to watch progress."
    ;;

  stop)
    echo -e "${YELLOW}■ Stopping stack...${NC}"
    docker compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✔ Stopped.${NC}"
    ;;

  restart)
    echo -e "${YELLOW}↻ Restarting stack...${NC}"
    docker compose -f "$COMPOSE_FILE" restart
    ;;

  logs)
    docker compose -f "$COMPOSE_FILE" logs -f --tail=100
    ;;

  status)
    docker compose -f "$COMPOSE_FILE" ps
    ;;

  pull-model)
    MODEL="${2:-codegemma:7b}"
    echo -e "${GREEN}⬇ Pulling model: ${MODEL}${NC}"
    docker exec ollama ollama pull "$MODEL"
    echo -e "${GREEN}✔ Model ready: ${MODEL}${NC}"
    ;;

  reset)
    echo -e "${RED}⚠ This will delete all data including downloaded models!${NC}"
    read -r -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
      docker compose -f "$COMPOSE_FILE" down -v
      echo -e "${GREEN}✔ Reset complete.${NC}"
    else
      echo "Aborted."
    fi
    ;;

  help|*)
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "  start        Start all services"
    echo "  stop         Stop all services"
    echo "  restart      Restart all services"
    echo "  logs         Tail logs from all containers"
    echo "  status       Show container status"
    echo "  pull-model   Pull or update a model (default: codegemma:7b)"
    echo "  reset        Full reset — removes volumes and model data"
    echo ""
    ;;
esac
