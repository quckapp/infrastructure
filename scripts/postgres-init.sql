-- QuckApp PostgreSQL Initialization Script
-- Creates databases for NestJS gateway services

-- Create databases
CREATE DATABASE quckapp_gateway;
CREATE DATABASE quckapp_notifications;

-- Create application user
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'quckapp') THEN
    CREATE USER quckapp WITH PASSWORD 'quckapp123';
  END IF;
END
$$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE quckapp TO quckapp;
GRANT ALL PRIVILEGES ON DATABASE quckapp_gateway TO quckapp;
GRANT ALL PRIVILEGES ON DATABASE quckapp_notifications TO quckapp;

-- Connect to gateway database and set up schema
\c quckapp_gateway;
GRANT ALL ON SCHEMA public TO quckapp;

-- Connect to notifications database and set up schema
\c quckapp_notifications;
GRANT ALL ON SCHEMA public TO quckapp;

-- Log completion
SELECT 'QuckApp PostgreSQL initialization complete' AS status;
