-- =============================================================================
-- QUCKAPP - ScyllaDB Schema
-- =============================================================================
-- Message storage optimized for append-heavy chat workloads.
-- Partition by conversation_id, cluster by created_at DESC for efficient
-- "load more messages" pagination.
-- =============================================================================

CREATE KEYSPACE IF NOT EXISTS quckapp
  WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 3}
  AND durable_writes = true;

USE quckapp;

-- ---------------------------------------------------------------------------
-- MESSAGES: Main table
-- Partition: conversation_id (all messages in one conversation co-located)
-- Clustering: created_at DESC, message_id DESC (newest first, tie-break by ID)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messages (
  conversation_id text,
  created_at      timestamp,
  message_id      uuid,
  sender_id       text,
  type            text,          -- text, image, video, audio, file, system, poll, code_snippet
  content         text,
  reply_to_id     uuid,
  mentions        set<text>,
  attachments     text,          -- JSON array: [{id, file_type, file_name, file_size, url, thumbnail_url}]
  is_edited       boolean,
  is_deleted      boolean,
  deleted_by      text,
  deleted_for     set<text>,     -- per-user soft deletion
  edited_at       timestamp,
  edit_history    text,          -- JSON array: [{content, edited_at}]
  is_forwarded    boolean,
  client_id       text,          -- client-side dedup key
  metadata        text,          -- JSON for extensibility (link previews, poll data, etc.)
  PRIMARY KEY ((conversation_id), created_at, message_id)
) WITH CLUSTERING ORDER BY (created_at DESC, message_id DESC)
  AND compaction = {
    'class': 'TimeWindowCompactionStrategy',
    'compaction_window_size': 1,
    'compaction_window_unit': 'DAYS'
  }
  AND gc_grace_seconds = 864000
  AND default_time_to_live = 0
  AND comment = 'Chat messages partitioned by conversation, ordered newest-first';

-- ---------------------------------------------------------------------------
-- REACTIONS: Separate table for high-write concurrency
-- One row per (conversation, message, emoji, user) tuple
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS message_reactions (
  conversation_id text,
  message_id      uuid,
  emoji           text,
  user_id         text,
  created_at      timestamp,
  PRIMARY KEY ((conversation_id, message_id), emoji, user_id)
) WITH comment = 'Message reactions, partitioned per message for concurrent writes';

-- ---------------------------------------------------------------------------
-- READ RECEIPTS: Track last-read position per user per conversation
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS read_receipts (
  conversation_id text,
  user_id         text,
  last_read_at    timestamp,
  last_read_msg   uuid,
  PRIMARY KEY ((conversation_id), user_id)
) WITH comment = 'Per-user read cursor in each conversation';

-- ---------------------------------------------------------------------------
-- DELIVERY RECEIPTS: Track message delivery per user
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS delivery_receipts (
  conversation_id text,
  message_id      uuid,
  user_id         text,
  delivered_at    timestamp,
  PRIMARY KEY ((conversation_id, message_id), user_id)
) WITH comment = 'Per-user delivery confirmation for each message';

-- ---------------------------------------------------------------------------
-- STARRED MESSAGES: Per-user bookmarks (partition by user for "my stars" queries)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS starred_messages (
  user_id         text,
  starred_at      timestamp,
  message_id      uuid,
  conversation_id text,
  PRIMARY KEY ((user_id), starred_at, message_id)
) WITH CLUSTERING ORDER BY (starred_at DESC, message_id DESC)
  AND comment = 'User-starred messages, newest-starred first';

-- ---------------------------------------------------------------------------
-- PINNED MESSAGES: Per-conversation pins
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pinned_messages (
  conversation_id text,
  pinned_at       timestamp,
  message_id      uuid,
  pinned_by       text,
  PRIMARY KEY ((conversation_id), pinned_at, message_id)
) WITH CLUSTERING ORDER BY (pinned_at DESC, message_id DESC)
  AND comment = 'Pinned messages per conversation';

-- ---------------------------------------------------------------------------
-- SCHEDULED MESSAGES: Future-send queue (partition by user)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS scheduled_messages (
  user_id         text,
  scheduled_for   timestamp,
  message_id      uuid,
  conversation_id text,
  type            text,
  content         text,
  attachments     text,
  PRIMARY KEY ((user_id), scheduled_for, message_id)
) WITH CLUSTERING ORDER BY (scheduled_for ASC, message_id ASC)
  AND comment = 'Scheduled messages ordered by send time';

-- ---------------------------------------------------------------------------
-- MESSAGES BY SENDER: Materialized view for sender-based lookups
-- Used for admin/moderation queries and per-user message history
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messages_by_sender (
  sender_id       text,
  created_at      timestamp,
  message_id      uuid,
  conversation_id text,
  content         text,
  PRIMARY KEY ((sender_id), created_at, message_id)
) WITH CLUSTERING ORDER BY (created_at DESC, message_id DESC)
  AND comment = 'Messages indexed by sender for admin/moderation queries';
