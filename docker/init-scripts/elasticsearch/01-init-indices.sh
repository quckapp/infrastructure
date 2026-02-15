#!/bin/bash
# =============================================================================
# QuckApp Elasticsearch Initialization Script
# =============================================================================
# Creates index templates and inserts seed data for search-service
# Run via bootstrap script after Elasticsearch is healthy
# =============================================================================

ES_HOST="${ES_HOST:-localhost}"
ES_PORT="${ES_PORT:-9200}"
ES_URL="http://${ES_HOST}:${ES_PORT}"

echo "Initializing Elasticsearch indices at ${ES_URL}..."

# =============================================================================
# Create Index: messages
# =============================================================================
curl -s -X PUT "${ES_URL}/messages" -H "Content-Type: application/json" -d '{
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
      "message_id": { "type": "keyword" },
      "conversation_id": { "type": "keyword" },
      "channel_id": { "type": "keyword" },
      "workspace_id": { "type": "keyword" },
      "sender_id": { "type": "keyword" },
      "content": { "type": "text", "analyzer": "message_analyzer" },
      "type": { "type": "keyword" },
      "created_at": { "type": "date" },
      "updated_at": { "type": "date" }
    }
  }
}'
echo ""

# =============================================================================
# Create Index: channels
# =============================================================================
curl -s -X PUT "${ES_URL}/channels" -H "Content-Type: application/json" -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "channel_id": { "type": "keyword" },
      "workspace_id": { "type": "keyword" },
      "name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "description": { "type": "text" },
      "type": { "type": "keyword" },
      "member_count": { "type": "integer" },
      "created_at": { "type": "date" }
    }
  }
}'
echo ""

# =============================================================================
# Create Index: files
# =============================================================================
curl -s -X PUT "${ES_URL}/files" -H "Content-Type: application/json" -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "file_id": { "type": "keyword" },
      "workspace_id": { "type": "keyword" },
      "user_id": { "type": "keyword" },
      "filename": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "original_filename": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "mime_type": { "type": "keyword" },
      "size_bytes": { "type": "long" },
      "created_at": { "type": "date" }
    }
  }
}'
echo ""

# =============================================================================
# Create Index: users
# =============================================================================
curl -s -X PUT "${ES_URL}/users" -H "Content-Type: application/json" -d '{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "user_id": { "type": "keyword" },
      "email": { "type": "keyword" },
      "username": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "full_name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "status": { "type": "keyword" },
      "role": { "type": "keyword" },
      "created_at": { "type": "date" }
    }
  }
}'
echo ""

# =============================================================================
# Seed Data: messages
# =============================================================================
echo "Seeding message data..."
curl -s -X POST "${ES_URL}/messages/_bulk" -H "Content-Type: application/x-ndjson" -d '
{"index":{}}
{"message_id":"m0000000-0000-0000-0000-000000000001","conversation_id":"c0000000-0000-0000-0000-000000000001","channel_id":"30000000-0000-0000-0000-000000000001","workspace_id":"10000000-0000-0000-0000-000000000001","sender_id":"00000000-0000-0000-0000-000000000001","content":"Hey, how is the project going?","type":"text","created_at":"2024-01-15T10:00:00Z"}
{"index":{}}
{"message_id":"m0000000-0000-0000-0000-000000000002","conversation_id":"c0000000-0000-0000-0000-000000000001","channel_id":"30000000-0000-0000-0000-000000000001","workspace_id":"10000000-0000-0000-0000-000000000001","sender_id":"00000000-0000-0000-0000-000000000002","content":"Going great! Almost done with the API.","type":"text","created_at":"2024-01-15T10:10:00Z"}
{"index":{}}
{"message_id":"m0000000-0000-0000-0000-000000000004","conversation_id":"c0000000-0000-0000-0000-000000000002","channel_id":"30000000-0000-0000-0000-000000000002","workspace_id":"10000000-0000-0000-0000-000000000001","sender_id":"00000000-0000-0000-0000-000000000001","content":"Welcome to Project Alpha everyone!","type":"text","created_at":"2024-01-15T09:00:00Z"}
{"index":{}}
{"message_id":"m0000000-0000-0000-0000-000000000005","conversation_id":"c0000000-0000-0000-0000-000000000002","channel_id":"30000000-0000-0000-0000-000000000002","workspace_id":"10000000-0000-0000-0000-000000000001","sender_id":"00000000-0000-0000-0000-000000000003","content":"Thanks! Excited to collaborate on the design system.","type":"text","created_at":"2024-01-15T09:15:00Z"}
{"index":{}}
{"message_id":"m0000000-0000-0000-0000-000000000007","conversation_id":"c0000000-0000-0000-0000-000000000002","channel_id":"30000000-0000-0000-0000-000000000002","workspace_id":"10000000-0000-0000-0000-000000000001","sender_id":"00000000-0000-0000-0000-000000000001","content":"Sprint planning is tomorrow at 10am.","type":"text","created_at":"2024-01-15T11:00:00Z"}
'
echo ""

# =============================================================================
# Seed Data: channels
# =============================================================================
echo "Seeding channel data..."
curl -s -X POST "${ES_URL}/channels/_bulk" -H "Content-Type: application/x-ndjson" -d '
{"index":{}}
{"channel_id":"30000000-0000-0000-0000-000000000001","workspace_id":"10000000-0000-0000-0000-000000000001","name":"general","description":"General discussion for the workspace","type":"public","member_count":4,"created_at":"2024-01-01T00:00:00Z"}
{"index":{}}
{"channel_id":"30000000-0000-0000-0000-000000000002","workspace_id":"10000000-0000-0000-0000-000000000001","name":"engineering","description":"Engineering team discussions","type":"public","member_count":3,"created_at":"2024-01-01T00:00:00Z"}
{"index":{}}
{"channel_id":"30000000-0000-0000-0000-000000000003","workspace_id":"10000000-0000-0000-0000-000000000001","name":"random","description":"Non-work banter and water cooler chat","type":"public","member_count":4,"created_at":"2024-01-01T00:00:00Z"}
{"index":{}}
{"channel_id":"30000000-0000-0000-0000-000000000004","workspace_id":"10000000-0000-0000-0000-000000000001","name":"admin-private","description":"Admin-only private channel","type":"private","member_count":2,"created_at":"2024-01-01T00:00:00Z"}
'
echo ""

# =============================================================================
# Seed Data: users
# =============================================================================
echo "Seeding user data..."
curl -s -X POST "${ES_URL}/users/_bulk" -H "Content-Type: application/x-ndjson" -d '
{"index":{}}
{"user_id":"00000000-0000-0000-0000-000000000001","email":"admin@quckapp.dev","username":"admin","full_name":"Admin User","status":"active","role":"admin","created_at":"2024-01-01T00:00:00Z"}
{"index":{}}
{"user_id":"00000000-0000-0000-0000-000000000002","email":"user@quckapp.dev","username":"testuser","full_name":"Test User","status":"active","role":"user","created_at":"2024-01-01T00:00:00Z"}
{"index":{}}
{"user_id":"00000000-0000-0000-0000-000000000003","email":"user2@quckapp.dev","username":"alice","full_name":"Alice Johnson","status":"active","role":"user","created_at":"2024-01-02T00:00:00Z"}
{"index":{}}
{"user_id":"00000000-0000-0000-0000-000000000004","email":"user3@quckapp.dev","username":"bob","full_name":"Bob Smith","status":"active","role":"moderator","created_at":"2024-01-02T00:00:00Z"}
{"index":{}}
{"user_id":"00000000-0000-0000-0000-000000000005","email":"bot@quckapp.dev","username":"quckbot","full_name":"QuckApp Bot","status":"active","role":"user","created_at":"2024-01-01T00:00:00Z"}
'
echo ""

# =============================================================================
# Seed Data: files
# =============================================================================
echo "Seeding file data..."
curl -s -X POST "${ES_URL}/files/_bulk" -H "Content-Type: application/x-ndjson" -d '
{"index":{}}
{"file_id":"me000000-0000-0000-0000-000000000001","workspace_id":"10000000-0000-0000-0000-000000000001","user_id":"00000000-0000-0000-0000-000000000001","filename":"avatar_admin.jpg","original_filename":"profile_photo.jpg","mime_type":"image/jpeg","size_bytes":245760,"created_at":"2024-01-08T00:00:00Z"}
{"index":{}}
{"file_id":"me000000-0000-0000-0000-000000000002","workspace_id":"10000000-0000-0000-0000-000000000001","user_id":"00000000-0000-0000-0000-000000000003","filename":"design_spec.pdf","original_filename":"Project Alpha Design Spec.pdf","mime_type":"application/pdf","size_bytes":1048576,"created_at":"2024-01-13T00:00:00Z"}
{"index":{}}
{"file_id":"me000000-0000-0000-0000-000000000003","workspace_id":"10000000-0000-0000-0000-000000000001","user_id":"00000000-0000-0000-0000-000000000002","filename":"screenshot.png","original_filename":"bug_screenshot.png","mime_type":"image/png","size_bytes":512000,"created_at":"2024-01-14T00:00:00Z"}
'
echo ""

echo "Elasticsearch initialization complete!"
