-- =============================================================================
-- QuckApp PostgreSQL Initialization Script
-- =============================================================================
-- This script runs when PostgreSQL starts for the first time.
-- It creates the initial database schema for local development.
-- =============================================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =============================================================================
-- Users Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    full_name VARCHAR(100),
    avatar_url TEXT,
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'deleted')),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
    metadata JSONB DEFAULT '{}',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- =============================================================================
-- Media Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('photo', 'video', 'audio', 'document')),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    s3_key TEXT NOT NULL,
    s3_bucket VARCHAR(100) NOT NULL,
    thumbnails JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'processing' CHECK (status IN ('processing', 'ready', 'failed', 'deleted')),
    is_public BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_media_user_id ON media(user_id);
CREATE INDEX idx_media_type ON media(type);
CREATE INDEX idx_media_status ON media(status);
CREATE INDEX idx_media_created_at ON media(created_at);
CREATE INDEX idx_media_s3_key ON media(s3_key);

-- =============================================================================
-- Conversations Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) DEFAULT 'direct' CHECK (type IN ('direct', 'group')),
    name VARCHAR(100),
    avatar_url TEXT,
    metadata JSONB DEFAULT '{}',
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_type ON conversations(type);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at);

-- =============================================================================
-- Conversation Participants Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS conversation_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('member', 'admin', 'owner')),
    muted BOOLEAN DEFAULT FALSE,
    last_read_at TIMESTAMPTZ,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);
CREATE INDEX idx_conv_participants_conv ON conversation_participants(conversation_id);

-- =============================================================================
-- Messages Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    type VARCHAR(20) DEFAULT 'text' CHECK (type IN ('text', 'image', 'video', 'audio', 'file', 'system')),
    content TEXT,
    media_id UUID REFERENCES media(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}',
    reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    edited_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- =============================================================================
-- Notifications Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    data JSONB DEFAULT '{}',
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at);
CREATE INDEX idx_notifications_read ON notifications(user_id, read_at);

-- =============================================================================
-- User Devices Table (for push notifications)
-- =============================================================================
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    device_info JSONB DEFAULT '{}',
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, device_token)
);

CREATE INDEX idx_user_devices_user ON user_devices(user_id);
CREATE INDEX idx_user_devices_platform ON user_devices(platform);

-- =============================================================================
-- Audit Log Table
-- =============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =============================================================================
-- Functions
-- =============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_media_updated_at
    BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- Seed Data (for development)
-- =============================================================================

-- Insert test users (UUIDs consistent across all databases)
INSERT INTO users (id, email, username, full_name, phone, email_verified, phone_verified, role, status)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@quckapp.dev', 'admin', 'Admin User', '+1234567890', true, true, 'admin', 'active'),
    ('00000000-0000-0000-0000-000000000002', 'user@quckapp.dev', 'testuser', 'Test User', '+1234567891', true, true, 'user', 'active'),
    ('00000000-0000-0000-0000-000000000003', 'user2@quckapp.dev', 'alice', 'Alice Johnson', '+1234567892', true, false, 'user', 'active'),
    ('00000000-0000-0000-0000-000000000004', 'user3@quckapp.dev', 'bob', 'Bob Smith', '+1234567893', true, false, 'moderator', 'active'),
    ('00000000-0000-0000-0000-000000000005', 'bot@quckapp.dev', 'quckbot', 'QuckApp Bot', NULL, true, false, 'user', 'active')
ON CONFLICT (email) DO NOTHING;

-- Insert test conversations
INSERT INTO conversations (id, type, name, last_message_at)
VALUES
    ('c0000000-0000-0000-0000-000000000001', 'direct', NULL, NOW() - INTERVAL '1 hour'),
    ('c0000000-0000-0000-0000-000000000002', 'group', 'Project Alpha', NOW() - INTERVAL '30 minutes')
ON CONFLICT DO NOTHING;

-- Insert conversation participants
INSERT INTO conversation_participants (id, conversation_id, user_id, role)
VALUES
    ('cp000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'member'),
    ('cp000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member'),
    ('cp000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'admin'),
    ('cp000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'member'),
    ('cp000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'member'),
    ('cp000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'member')
ON CONFLICT DO NOTHING;

-- Insert sample messages
INSERT INTO messages (id, conversation_id, sender_id, type, content, created_at)
VALUES
    ('m0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'text', 'Hey, how is the project going?', NOW() - INTERVAL '2 hours'),
    ('m0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'text', 'Going great! Almost done with the API.', NOW() - INTERVAL '1 hour 50 minutes'),
    ('m0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'text', 'Awesome, let me know if you need any help.', NOW() - INTERVAL '1 hour'),
    ('m0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'text', 'Welcome to Project Alpha everyone!', NOW() - INTERVAL '3 hours'),
    ('m0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'text', 'Thanks! Excited to collaborate.', NOW() - INTERVAL '2 hours 45 minutes'),
    ('m0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'text', 'Looking forward to it!', NOW() - INTERVAL '2 hours 30 minutes'),
    ('m0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'text', 'Sprint planning is tomorrow at 10am.', NOW() - INTERVAL '1 hour'),
    ('m0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'text', 'Will be there!', NOW() - INTERVAL '45 minutes'),
    ('m0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'text', 'Can we review the designs first?', NOW() - INTERVAL '30 minutes'),
    ('m0000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'text', 'Sure, I will share the Figma link.', NOW() - INTERVAL '15 minutes')
ON CONFLICT DO NOTHING;

-- Insert sample notifications
INSERT INTO notifications (id, user_id, type, title, body, data, created_at)
VALUES
    ('n0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'mention', 'You were mentioned', 'Admin mentioned you in #general', '{"channel_id": "30000000-0000-0000-0000-000000000001"}', NOW() - INTERVAL '2 hours'),
    ('n0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'message', 'New message', 'Alice: Can we review the designs first?', '{"conversation_id": "c0000000-0000-0000-0000-000000000002"}', NOW() - INTERVAL '30 minutes'),
    ('n0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', 'workspace_invite', 'Workspace invitation', 'You were invited to QuckApp Dev Workspace', '{"workspace_id": "10000000-0000-0000-0000-000000000001"}', NOW() - INTERVAL '1 day'),
    ('n0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'system', 'System update', 'QuckApp has been updated to v2.1.0', '{}', NOW() - INTERVAL '3 days'),
    ('n0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000004', 'message', 'New direct message', 'Admin sent you a message', '{"conversation_id": "c0000000-0000-0000-0000-000000000001"}', NOW() - INTERVAL '1 hour')
ON CONFLICT DO NOTHING;

-- Insert sample media
INSERT INTO media (id, user_id, type, filename, original_filename, mime_type, size_bytes, s3_key, s3_bucket, status, created_at)
VALUES
    ('me000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'photo', 'avatar_admin.jpg', 'profile_photo.jpg', 'image/jpeg', 245760, 'avatars/00000000-0000-0000-0000-000000000001/avatar.jpg', 'quckapp-media-dev', 'ready', NOW() - INTERVAL '7 days'),
    ('me000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'document', 'design_spec.pdf', 'Project Alpha Design Spec.pdf', 'application/pdf', 1048576, 'documents/design_spec_v1.pdf', 'quckapp-media-dev', 'ready', NOW() - INTERVAL '2 days'),
    ('me000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'photo', 'screenshot.png', 'bug_screenshot.png', 'image/png', 512000, 'uploads/screenshot_20240101.png', 'quckapp-media-dev', 'ready', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- Grants
-- =============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO quckapp;

-- =============================================================================
-- Complete
-- =============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Database initialization complete!';
END $$;
