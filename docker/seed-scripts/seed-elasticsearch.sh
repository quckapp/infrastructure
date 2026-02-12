#!/usr/bin/env bash
# =============================================================================
# QuckApp Elasticsearch Seed Orchestrator
# =============================================================================
set -euo pipefail

ES_URL="${ES_URL:-http://localhost:9200}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/../init-scripts/elasticsearch/01-init-indices.sh"

echo "=== Elasticsearch Seed Orchestrator ==="

# Wait for ES to be healthy
echo "Checking Elasticsearch at $ES_URL..."
for i in $(seq 1 30); do
  if curl -s "$ES_URL/_cluster/health" | grep -q '"status":"green"\|"status":"yellow"'; then
    echo "Elasticsearch is ready."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "ERROR: Elasticsearch not ready after 30 attempts."
    exit 1
  fi
  echo "Waiting for Elasticsearch... ($i/30)"
  sleep 2
done

# Check if indices already exist
if curl -s "$ES_URL/messages" | grep -q '"messages"'; then
  echo "Indices already exist. Skipping seed."
  echo "To re-seed, delete indices first: curl -X DELETE '$ES_URL/messages,channels,files,users'"
  exit 0
fi

# Run init script
echo "Running init script..."
bash "$INIT_SCRIPT"
echo "Done."
