-- =============================================================================
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

-- Grant all privileges to quckapp user
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

FLUSH PRIVILEGES;
