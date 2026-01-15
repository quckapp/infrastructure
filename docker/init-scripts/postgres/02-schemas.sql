-- =============================================================================
-- QUCKAPP - PostgreSQL Additional Schemas
-- =============================================================================
-- Creates domain-specific schemas for microservices
-- =============================================================================

-- Create schemas for different domains
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS workspaces;
CREATE SCHEMA IF NOT EXISTS messaging;
CREATE SCHEMA IF NOT EXISTS files;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS admin;

-- Grant schema usage to application user
GRANT USAGE ON SCHEMA auth TO quckapp;
GRANT USAGE ON SCHEMA users TO quckapp;
GRANT USAGE ON SCHEMA workspaces TO quckapp;
GRANT USAGE ON SCHEMA messaging TO quckapp;
GRANT USAGE ON SCHEMA files TO quckapp;
GRANT USAGE ON SCHEMA notifications TO quckapp;
GRANT USAGE ON SCHEMA admin TO quckapp;

-- Grant all privileges on all tables in schemas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA users TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA workspaces TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA messaging TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA files TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notifications TO quckapp;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA admin TO quckapp;

-- Grant sequence usage
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA users TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA workspaces TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA messaging TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA files TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA notifications TO quckapp;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA admin TO quckapp;

-- Set default search path
ALTER DATABASE quckapp SET search_path TO public, auth, users, workspaces, messaging, files, notifications, admin;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'QuckApp PostgreSQL schemas initialization complete';
END $$;
