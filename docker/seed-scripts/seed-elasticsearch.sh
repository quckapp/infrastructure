#!/bin/bash
# =============================================================================
# QuckApp - Elasticsearch Seed Script
# =============================================================================
# Seeds Elasticsearch with index templates and sample data.
# Called by the bootstrap script after Elasticsearch is healthy.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="${SCRIPT_DIR}/../init-scripts/elasticsearch/01-init-indices.sh"

ES_HOST="${ES_HOST:-localhost}"
ES_PORT="${ES_PORT:-9200}"

echo "=== Elasticsearch Seed Script ==="

# Check if Elasticsearch is reachable
if ! curl -sf "http://${ES_HOST}:${ES_PORT}/_cluster/health" > /dev/null 2>&1; then
    echo "ERROR: Elasticsearch is not reachable at http://${ES_HOST}:${ES_PORT}"
    exit 1
fi

# Check if indices already exist
if curl -sf "http://${ES_HOST}:${ES_PORT}/messages" > /dev/null 2>&1; then
    echo "Elasticsearch indices already exist. Skipping seed."
    echo "To re-seed, delete indices first: curl -X DELETE 'http://${ES_HOST}:${ES_PORT}/messages,channels,files,users'"
    exit 0
fi

# Run the init script
if [ -f "$INIT_SCRIPT" ]; then
    echo "Running Elasticsearch init script..."
    ES_HOST="$ES_HOST" ES_PORT="$ES_PORT" bash "$INIT_SCRIPT"
    echo "Elasticsearch seeding complete!"
else
    echo "ERROR: Init script not found at $INIT_SCRIPT"
    exit 1
fi
