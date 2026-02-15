-- =============================================================================
-- QuckApp MySQL Seed Data (Development)
-- =============================================================================
-- UUIDs are consistent across all databases (Postgres, MySQL, MongoDB, etc.)
-- Test users: 00000000-0000-0000-0000-000000000001 through 000000000005
-- =============================================================================

-- =============================================================================
-- Auth Service Seed Data (quckapp_auth)
-- =============================================================================
USE quckapp_auth;

CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    full_name VARCHAR(100),
    avatar_url TEXT,
    status ENUM('active', 'inactive', 'suspended', 'deleted') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    login_count INT DEFAULT 0,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_status (status)
);

CREATE TABLE IF NOT EXISTS sessions (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    device_info JSON,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS api_keys (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    name VARCHAR(100) NOT NULL,
    key_prefix VARCHAR(10) NOT NULL,
    key_hash VARCHAR(255) NOT NULL,
    permissions JSON,
    rate_limit_per_minute INT DEFAULT 60,
    rate_limit_per_hour INT DEFAULT 1000,
    expires_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key_prefix (key_prefix),
    INDEX idx_user_id (user_id)
);

-- Seed users (bcrypt hash of 'password123')
INSERT INTO users (id, email, phone, password_hash, full_name, email_verified, status) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@quckapp.dev', '+1234567890', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin User', TRUE, 'active'),
    ('00000000-0000-0000-0000-000000000002', 'user@quckapp.dev', '+1234567891', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Test User', TRUE, 'active'),
    ('00000000-0000-0000-0000-000000000003', 'user2@quckapp.dev', '+1234567892', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Alice Johnson', TRUE, 'active'),
    ('00000000-0000-0000-0000-000000000004', 'user3@quckapp.dev', '+1234567893', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Bob Smith', TRUE, 'active'),
    ('00000000-0000-0000-0000-000000000005', 'bot@quckapp.dev', NULL, NULL, 'QuckApp Bot', TRUE, 'active');

-- =============================================================================
-- Workspace Service Seed Data (quckapp_workspaces)
-- =============================================================================
USE quckapp_workspaces;

CREATE TABLE IF NOT EXISTS workspaces (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    owner_id CHAR(36) NOT NULL,
    plan ENUM('free', 'pro', 'enterprise') DEFAULT 'free',
    status ENUM('active', 'archived', 'deleted') DEFAULT 'active',
    settings JSON DEFAULT (JSON_OBJECT()),
    member_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner_id (owner_id),
    INDEX idx_slug (slug),
    INDEX idx_status (status)
);

CREATE TABLE IF NOT EXISTS workspace_members (
    id CHAR(36) PRIMARY KEY,
    workspace_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    role ENUM('owner', 'admin', 'member', 'guest') DEFAULT 'member',
    status ENUM('active', 'invited', 'deactivated') DEFAULT 'active',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_workspace_user (workspace_id, user_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE CASCADE
);

INSERT INTO workspaces (id, name, slug, description, owner_id, plan, member_count) VALUES
    ('10000000-0000-0000-0000-000000000001', 'QuckApp Dev Workspace', 'quckapp-dev', 'Default development workspace for QuckApp team', '00000000-0000-0000-0000-000000000001', 'enterprise', 4),
    ('10000000-0000-0000-0000-000000000002', 'Design Team', 'design-team', 'Design team workspace', '00000000-0000-0000-0000-000000000003', 'pro', 2);

INSERT INTO workspace_members (id, workspace_id, user_id, role, status) VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner', 'active'),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member', 'active'),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'admin', 'active'),
    ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'member', 'active'),
    ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'owner', 'active'),
    ('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 'member', 'active');

-- =============================================================================
-- Channel Service Seed Data (quckapp_channels)
-- =============================================================================
USE quckapp_channels;

CREATE TABLE IF NOT EXISTS channels (
    id CHAR(36) PRIMARY KEY,
    workspace_id CHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    type ENUM('public', 'private', 'direct') DEFAULT 'public',
    topic TEXT,
    created_by CHAR(36) NOT NULL,
    is_archived BOOLEAN DEFAULT FALSE,
    member_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_workspace_slug (workspace_id, slug),
    INDEX idx_workspace_id (workspace_id),
    INDEX idx_type (type)
);

CREATE TABLE IF NOT EXISTS channel_members (
    id CHAR(36) PRIMARY KEY,
    channel_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    role ENUM('owner', 'admin', 'member') DEFAULT 'member',
    notifications ENUM('all', 'mentions', 'none') DEFAULT 'all',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_channel_user (channel_id, user_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

INSERT INTO channels (id, workspace_id, name, slug, description, type, created_by, member_count) VALUES
    ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'general', 'general', 'General discussion for the workspace', 'public', '00000000-0000-0000-0000-000000000001', 4),
    ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'engineering', 'engineering', 'Engineering team discussions', 'public', '00000000-0000-0000-0000-000000000001', 3),
    ('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'random', 'random', 'Non-work banter and water cooler chat', 'public', '00000000-0000-0000-0000-000000000001', 4),
    ('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'admin-private', 'admin-private', 'Admin-only private channel', 'private', '00000000-0000-0000-0000-000000000001', 2),
    ('30000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', 'design-general', 'design-general', 'Design team general', 'public', '00000000-0000-0000-0000-000000000003', 2);

INSERT INTO channel_members (id, channel_id, user_id, role) VALUES
    ('40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner'),
    ('40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member'),
    ('40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member'),
    ('40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'member'),
    ('40000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'owner'),
    ('40000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'member'),
    ('40000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'member'),
    ('40000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'owner'),
    ('40000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000003', 'admin');

-- =============================================================================
-- Bookmark Service Seed Data (quckapp_bookmarks)
-- =============================================================================
USE quckapp_bookmarks;

-- Note: bookmark-service uses GORM auto-migration, so tables are created by the service.
-- We seed data into known table structures that match the GORM models.

-- =============================================================================
-- Thread Service Seed Data (quckapp_threads)
-- =============================================================================
USE quckapp_threads;

CREATE TABLE IF NOT EXISTS threads (
    id CHAR(36) PRIMARY KEY,
    channel_id CHAR(36) NOT NULL,
    parent_message_id CHAR(36) NOT NULL,
    created_by CHAR(36) NOT NULL,
    reply_count INT DEFAULT 0,
    participant_count INT DEFAULT 0,
    last_reply_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_channel_id (channel_id),
    INDEX idx_parent_message_id (parent_message_id)
);

INSERT INTO threads (id, channel_id, parent_message_id, created_by, reply_count, participant_count) VALUES
    ('50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 3, 2),
    ('50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 2, 2);

SELECT 'MySQL seed data loaded successfully!' AS status;
