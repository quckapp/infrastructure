#!/usr/bin/env bash
# =============================================================================
# QuckApp Elasticsearch Index Initialization
# =============================================================================
set -euo pipefail

ES_URL="${ES_URL:-http://localhost:9200}"

echo "=== Creating Elasticsearch indices ==="

# Messages index
curl -s -X PUT "$ES_URL/messages" -H 'Content-Type: application/json' -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "analysis": {
      "analyzer": {
        "message_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "snowball"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "content": { "type": "text", "analyzer": "message_analyzer" },
      "senderId": { "type": "keyword" },
      "channelId": { "type": "keyword" },
      "workspaceId": { "type": "keyword" },
      "type": { "type": "keyword" },
      "createdAt": { "type": "date" }
    }
  }
}' 2>/dev/null && echo " [OK] messages index created" || echo " [SKIP] messages index exists"

# Channels index
curl -s -X PUT "$ES_URL/channels" -H 'Content-Type: application/json' -d '{
  "settings": { "number_of_shards": 1, "number_of_replicas": 0 },
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "description": { "type": "text" },
      "workspaceId": { "type": "keyword" },
      "type": { "type": "keyword" },
      "createdAt": { "type": "date" }
    }
  }
}' 2>/dev/null && echo " [OK] channels index created" || echo " [SKIP] channels index exists"

# Files index
curl -s -X PUT "$ES_URL/files" -H 'Content-Type: application/json' -d '{
  "settings": { "number_of_shards": 1, "number_of_replicas": 0 },
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "filename": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "mimeType": { "type": "keyword" },
      "userId": { "type": "keyword" },
      "workspaceId": { "type": "keyword" },
      "sizeBytes": { "type": "long" },
      "createdAt": { "type": "date" }
    }
  }
}' 2>/dev/null && echo " [OK] files index created" || echo " [SKIP] files index exists"

# Users index
curl -s -X PUT "$ES_URL/users" -H 'Content-Type: application/json' -d '{
  "settings": { "number_of_shards": 1, "number_of_replicas": 0 },
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "email": { "type": "keyword" },
      "username": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "fullName": { "type": "text" },
      "status": { "type": "keyword" },
      "createdAt": { "type": "date" }
    }
  }
}' 2>/dev/null && echo " [OK] users index created" || echo " [SKIP] users index exists"

echo ""
echo "=== Seeding sample documents ==="

# Seed messages
curl -s -X POST "$ES_URL/messages/_bulk" -H 'Content-Type: application/x-ndjson' -d '
{"index":{"_id":"msg-001"}}
{"id":"msg-001","content":"Welcome to QuckApp! This is the general channel.","senderId":"00000000-0000-0000-0000-000000000001","channelId":"30000000-0000-0000-0000-000000000001","workspaceId":"10000000-0000-0000-0000-000000000001","type":"text","createdAt":"2024-01-15T10:00:00Z"}
{"index":{"_id":"msg-002"}}
{"id":"msg-002","content":"Hey everyone, the new deployment pipeline is ready for review.","senderId":"00000000-0000-0000-0000-000000000002","channelId":"30000000-0000-0000-0000-000000000002","workspaceId":"10000000-0000-0000-0000-000000000001","type":"text","createdAt":"2024-01-15T11:00:00Z"}
{"index":{"_id":"msg-003"}}
{"id":"msg-003","content":"Shared the design mockup in the files section.","senderId":"00000000-0000-0000-0000-000000000003","channelId":"30000000-0000-0000-0000-000000000001","workspaceId":"10000000-0000-0000-0000-000000000001","type":"text","createdAt":"2024-01-15T12:00:00Z"}
' 2>/dev/null && echo " [OK] messages seeded"

# Seed channels
curl -s -X POST "$ES_URL/channels/_bulk" -H 'Content-Type: application/x-ndjson' -d '
{"index":{"_id":"30000000-0000-0000-0000-000000000001"}}
{"id":"30000000-0000-0000-0000-000000000001","name":"general","description":"General discussion","workspaceId":"10000000-0000-0000-0000-000000000001","type":"public","createdAt":"2024-01-01T00:00:00Z"}
{"index":{"_id":"30000000-0000-0000-0000-000000000002"}}
{"id":"30000000-0000-0000-0000-000000000002","name":"engineering","description":"Engineering team","workspaceId":"10000000-0000-0000-0000-000000000001","type":"public","createdAt":"2024-01-01T00:00:00Z"}
' 2>/dev/null && echo " [OK] channels seeded"

# Seed users
curl -s -X POST "$ES_URL/users/_bulk" -H 'Content-Type: application/x-ndjson' -d '
{"index":{"_id":"00000000-0000-0000-0000-000000000001"}}
{"id":"00000000-0000-0000-0000-000000000001","email":"admin@quckapp.dev","username":"admin","fullName":"Admin User","status":"active","createdAt":"2024-01-01T00:00:00Z"}
{"index":{"_id":"00000000-0000-0000-0000-000000000002"}}
{"id":"00000000-0000-0000-0000-000000000002","email":"user@quckapp.dev","username":"testuser","fullName":"Test User","status":"active","createdAt":"2024-01-01T00:00:00Z"}
{"index":{"_id":"00000000-0000-0000-0000-000000000003"}}
{"id":"00000000-0000-0000-0000-000000000003","email":"alice@quckapp.dev","username":"alice","fullName":"Alice Developer","status":"active","createdAt":"2024-01-02T00:00:00Z"}
' 2>/dev/null && echo " [OK] users seeded"

echo ""
echo "=== Elasticsearch initialization complete ==="
