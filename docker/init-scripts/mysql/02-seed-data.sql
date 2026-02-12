-- =============================================================================
-- QuckApp MySQL Seed Data
-- =============================================================================
-- Consistent UUIDs matching Postgres seed data:
--   user1: 00000000-0000-0000-0000-000000000001 (admin)
--   user2: 00000000-0000-0000-0000-000000000002 (testuser)
--   user3: 00000000-0000-0000-0000-000000000003 (alice)
--   user4: 00000000-0000-0000-0000-000000000004 (bob)
--   user5: 00000000-0000-0000-0000-000000000005 (bot)
-- =============================================================================

-- =============================================================================
-- Auth Service (quckapp_auth)
-- =============================================================================
USE quckapp_auth;

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    two_fa_enabled BOOLEAN DEFAULT FALSE,
    two_fa_secret VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- bcrypt hash for 'password123'
INSERT INTO users (id, email, password_hash, email_verified, status) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@quckapp.dev', '$2a$12$LJ3m4ys2BEYnZn3E6Dzx6e1dBs9bHCHzPKZLrJGx5F8zOqN/q0Sim', true, 'active'),
('00000000-0000-0000-0000-000000000002', 'user@quckapp.dev', '$2a$12$LJ3m4ys2BEYnZn3E6Dzx6e1dBs9bHCHzPKZLrJGx5F8zOqN/q0Sim', true, 'active'),
('00000000-0000-0000-0000-000000000003', 'alice@quckapp.dev', '$2a$12$LJ3m4ys2BEYnZn3E6Dzx6e1dBs9bHCHzPKZLrJGx5F8zOqN/q0Sim', true, 'active'),
('00000000-0000-0000-0000-000000000004', 'bob@quckapp.dev', '$2a$12$LJ3m4ys2BEYnZn3E6Dzx6e1dBs9bHCHzPKZLrJGx5F8zOqN/q0Sim', true, 'active'),
('00000000-0000-0000-0000-000000000005', 'bot@quckapp.dev', '$2a$12$LJ3m4ys2BEYnZn3E6Dzx6e1dBs9bHCHzPKZLrJGx5F8zOqN/q0Sim', true, 'active')
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- =============================================================================
-- Workspaces Service (quckapp_workspaces)
-- =============================================================================
USE quckapp_workspaces;

CREATE TABLE IF NOT EXISTS workspaces (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    owner_id VARCHAR(36) NOT NULL,
    icon_url TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workspaces_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS workspace_members (
    id VARCHAR(36) PRIMARY KEY,
    workspace_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    role VARCHAR(20) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_workspace_member (workspace_id, user_id),
    INDEX idx_members_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO workspaces (id, name, slug, description, owner_id) VALUES
('10000000-0000-0000-0000-000000000001', 'QuckApp Dev', 'quckapp-dev', 'Development workspace for QuckApp team', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000002', 'QuckApp Design', 'quckapp-design', 'Design team workspace', '00000000-0000-0000-0000-000000000003')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO workspace_members (id, workspace_id, user_id, role) VALUES
('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'admin'),
('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member'),
('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member'),
('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'member'),
('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000005', 'member'),
('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'admin')
ON DUPLICATE KEY UPDATE role = VALUES(role);

-- =============================================================================
-- Channels Service (quckapp_channels)
-- =============================================================================
USE quckapp_channels;

CREATE TABLE IF NOT EXISTS channels (
    id VARCHAR(36) PRIMARY KEY,
    workspace_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(20) DEFAULT 'public',
    created_by VARCHAR(36) NOT NULL,
    archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_channels_workspace (workspace_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS channel_members (
    id VARCHAR(36) PRIMARY KEY,
    channel_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    role VARCHAR(20) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_channel_member (channel_id, user_id),
    INDEX idx_cmembers_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO channels (id, workspace_id, name, description, type, created_by) VALUES
('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'general', 'General discussion', 'public', '00000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'engineering', 'Engineering team', 'public', '00000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'random', 'Random chat', 'public', '00000000-0000-0000-0000-000000000002'),
('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'devops', 'DevOps and infrastructure', 'private', '00000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000002', 'design-general', 'Design discussions', 'public', '00000000-0000-0000-0000-000000000003')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO channel_members (id, channel_id, user_id, role) VALUES
('40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'admin'),
('40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'member'),
('40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'member'),
('40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'admin'),
('40000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'member'),
('40000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'member'),
('40000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000002', 'admin'),
('40000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'admin'),
('40000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'admin')
ON DUPLICATE KEY UPDATE role = VALUES(role);

-- =============================================================================
-- Threads Service (quckapp_threads)
-- =============================================================================
USE quckapp_threads;

CREATE TABLE IF NOT EXISTS threads (
    id VARCHAR(36) PRIMARY KEY,
    channel_id VARCHAR(36) NOT NULL,
    parent_message_id VARCHAR(36) NOT NULL,
    created_by VARCHAR(36) NOT NULL,
    reply_count INT DEFAULT 0,
    last_reply_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_threads_channel (channel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO threads (id, channel_id, parent_message_id, created_by, reply_count) VALUES
('50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 3),
('50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 1)
ON DUPLICATE KEY UPDATE reply_count = VALUES(reply_count);
