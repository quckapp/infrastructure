-- =============================================================================
<<<<<<< HEAD
-- QuckApp MySQL Database Initialization
-- =============================================================================
-- Creates databases for all MySQL-backed services and grants permissions.
-- =============================================================================

-- Spring Boot services
CREATE DATABASE IF NOT EXISTS quckapp_auth;
CREATE DATABASE IF NOT EXISTS quckapp_users;
CREATE DATABASE IF NOT EXISTS quckapp_permissions;
CREATE DATABASE IF NOT EXISTS quckapp_audit;
CREATE DATABASE IF NOT EXISTS quckapp_admin;
CREATE DATABASE IF NOT EXISTS quckapp_security;

-- Go services
CREATE DATABASE IF NOT EXISTS quckapp_workspaces;
CREATE DATABASE IF NOT EXISTS quckapp_channels;
CREATE DATABASE IF NOT EXISTS quckapp_threads;
CREATE DATABASE IF NOT EXISTS quckapp_bookmarks;
CREATE DATABASE IF NOT EXISTS quckapp_reminders;
CREATE DATABASE IF NOT EXISTS quckapp_search;

-- Python services
CREATE DATABASE IF NOT EXISTS quckapp_analytics;
CREATE DATABASE IF NOT EXISTS quckapp_insights;
CREATE DATABASE IF NOT EXISTS quckapp_moderation;
CREATE DATABASE IF NOT EXISTS quckapp_exports;
CREATE DATABASE IF NOT EXISTS quckapp_integrations;

-- Elixir services
CREATE DATABASE IF NOT EXISTS quckapp_realtime;

-- Grant all privileges to quckapp user
=======
-- QuckApp MySQL Initialization Script
-- =============================================================================
-- Creates databases for all MySQL-backed services (Spring Boot + Go)
-- Runs automatically on first container start via docker-entrypoint-initdb.d
-- =============================================================================

-- =============================================================================
-- Create Databases
-- =============================================================================

-- Spring Boot Services
CREATE DATABASE IF NOT EXISTS quckapp_auth
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_users
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_permissions
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_audit
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_admin
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_security
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Go Services
CREATE DATABASE IF NOT EXISTS quckapp_workspaces
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_channels
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_threads
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_bookmarks
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_reminders
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS quckapp_search
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =============================================================================
-- Grant Privileges to Application User
-- =============================================================================
>>>>>>> 46061ba01865df763bcbb020e83d9c6b23b687f7
GRANT ALL PRIVILEGES ON quckapp_auth.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_users.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_permissions.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_audit.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_admin.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_security.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_workspaces.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_channels.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_threads.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_bookmarks.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_reminders.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_search.* TO 'quckapp'@'%';
<<<<<<< HEAD
GRANT ALL PRIVILEGES ON quckapp_analytics.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_insights.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_moderation.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_exports.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_integrations.* TO 'quckapp'@'%';
GRANT ALL PRIVILEGES ON quckapp_realtime.* TO 'quckapp'@'%';

FLUSH PRIVILEGES;
=======

FLUSH PRIVILEGES;

SELECT 'MySQL databases created successfully!' AS status;
>>>>>>> 46061ba01865df763bcbb020e83d9c6b23b687f7
