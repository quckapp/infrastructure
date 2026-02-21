-- =============================================================================
-- QUCKAPP - PostgreSQL Conversation Metadata Schema
-- =============================================================================
-- Conversation metadata, participants, settings, blocked users, call records.
-- Uses the 'messaging' schema created in 02-schemas.sql.
-- =============================================================================

SET search_path TO messaging, public;

-- ---------------------------------------------------------------------------
-- CONVERSATIONS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messaging.conversations (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type                     VARCHAR(20) NOT NULL DEFAULT 'direct',  -- direct, group
  name                     VARCHAR(255),
  description              TEXT,
  avatar_url               TEXT,
  created_by               VARCHAR(100) NOT NULL,
  is_archived              BOOLEAN DEFAULT FALSE,
  last_message_at          TIMESTAMPTZ,
  last_message_preview     TEXT,
  last_message_sender_id   VARCHAR(100),
  disappearing_ttl_seconds INTEGER,
  metadata                 JSONB DEFAULT '{}',
  created_at               TIMESTAMPTZ DEFAULT NOW(),
  updated_at               TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conv_created_by
  ON messaging.conversations(created_by);
CREATE INDEX IF NOT EXISTS idx_conv_last_message
  ON messaging.conversations(last_message_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_conv_type
  ON messaging.conversations(type);

-- ---------------------------------------------------------------------------
-- PARTICIPANTS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messaging.participants (
  conversation_id UUID        NOT NULL REFERENCES messaging.conversations(id) ON DELETE CASCADE,
  user_id         VARCHAR(100) NOT NULL,
  role            VARCHAR(20)  DEFAULT 'member',  -- owner, admin, member
  nickname        VARCHAR(100),
  is_muted        BOOLEAN      DEFAULT FALSE,
  muted_until     TIMESTAMPTZ,
  unread_count    INTEGER      DEFAULT 0,
  last_read_at    TIMESTAMPTZ,
  joined_at       TIMESTAMPTZ  DEFAULT NOW(),
  left_at         TIMESTAMPTZ,
  PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_part_user
  ON messaging.participants(user_id);
CREATE INDEX IF NOT EXISTS idx_part_active
  ON messaging.participants(user_id) WHERE left_at IS NULL;

-- ---------------------------------------------------------------------------
-- USER SETTINGS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messaging.user_settings (
  user_id              VARCHAR(100) PRIMARY KEY,
  notification_sound   BOOLEAN     DEFAULT TRUE,
  notification_preview BOOLEAN     DEFAULT TRUE,
  read_receipts        BOOLEAN     DEFAULT TRUE,
  typing_indicators    BOOLEAN     DEFAULT TRUE,
  last_seen_visible    BOOLEAN     DEFAULT TRUE,
  theme                VARCHAR(20) DEFAULT 'system',
  language             VARCHAR(10) DEFAULT 'en',
  metadata             JSONB       DEFAULT '{}',
  updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- BLOCKED USERS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messaging.blocked_users (
  blocker_id VARCHAR(100) NOT NULL,
  blocked_id VARCHAR(100) NOT NULL,
  blocked_at TIMESTAMPTZ  DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id)
);

CREATE INDEX IF NOT EXISTS idx_blocked_by_blocker
  ON messaging.blocked_users(blocker_id);

-- ---------------------------------------------------------------------------
-- CALL RECORDS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messaging.call_records (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id  UUID REFERENCES messaging.conversations(id),
  caller_id        VARCHAR(100)  NOT NULL,
  type             VARCHAR(20)   NOT NULL,  -- one_to_one, group, huddle
  status           VARCHAR(20)   NOT NULL,  -- ringing, active, ended, missed, rejected
  livekit_room     VARCHAR(255),
  started_at       TIMESTAMPTZ   DEFAULT NOW(),
  answered_at      TIMESTAMPTZ,
  ended_at         TIMESTAMPTZ,
  ended_by         VARCHAR(100),
  duration_seconds INTEGER,
  reject_reason    TEXT,
  metadata         JSONB         DEFAULT '{}',
  created_at       TIMESTAMPTZ   DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS messaging.call_participants (
  call_id   UUID         NOT NULL REFERENCES messaging.call_records(id) ON DELETE CASCADE,
  user_id   VARCHAR(100) NOT NULL,
  joined_at TIMESTAMPTZ  DEFAULT NOW(),
  left_at   TIMESTAMPTZ,
  PRIMARY KEY (call_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_calls_conversation
  ON messaging.call_records(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calls_caller
  ON messaging.call_records(caller_id, created_at DESC);

-- ---------------------------------------------------------------------------
-- HELPER FUNCTION: Auto-update updated_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION messaging.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_conversations_updated
  BEFORE UPDATE ON messaging.conversations
  FOR EACH ROW EXECUTE FUNCTION messaging.update_updated_at();

CREATE TRIGGER trg_user_settings_updated
  BEFORE UPDATE ON messaging.user_settings
  FOR EACH ROW EXECUTE FUNCTION messaging.update_updated_at();

-- Log completion
DO $$
BEGIN
  RAISE NOTICE 'QuckApp conversations schema initialization complete';
END $$;
