-- =============================================================================
-- QuckApp ClickHouse Seed Data (Development)
-- =============================================================================
-- Analytics data for dashboards and testing
-- Uses consistent UUIDs from other databases
-- =============================================================================

-- =============================================================================
-- Message Events (20 events spanning last 7 days)
-- =============================================================================
INSERT INTO quckapp_analytics.message_events (
    event_id, event_type, user_id, workspace_id, channel_id, message_id,
    message_type, timestamp
) VALUES
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000001', 'text', now() - INTERVAL 7 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000002', 'text', now() - INTERVAL 6 DAY + INTERVAL 3 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', 'm0000000-0000-0000-0000-000000000003', 'text', now() - INTERVAL 6 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', generateUUIDv4(), 'text', now() - INTERVAL 5 DAY + INTERVAL 2 HOUR),
    (generateUUIDv4(), 'message_edited', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000002', 'text', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', generateUUIDv4(), 'image', now() - INTERVAL 4 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 4 DAY + INTERVAL 5 HOUR),
    (generateUUIDv4(), 'reaction_added', '00000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'm0000000-0000-0000-0000-000000000001', 'text', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', generateUUIDv4(), 'text', now() - INTERVAL 3 DAY + INTERVAL 1 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', generateUUIDv4(), 'file', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 2 DAY + INTERVAL 4 HOUR),
    (generateUUIDv4(), 'message_deleted', '00000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', generateUUIDv4(), 'text', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', generateUUIDv4(), 'text', now() - INTERVAL 1 DAY + INTERVAL 2 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 12 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', generateUUIDv4(), 'text', now() - INTERVAL 6 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 3 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', generateUUIDv4(), 'text', now() - INTERVAL 1 HOUR),
    (generateUUIDv4(), 'message_sent', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', generateUUIDv4(), 'text', now() - INTERVAL 30 MINUTE);

-- =============================================================================
-- User Activity (15 entries)
-- =============================================================================
INSERT INTO quckapp_analytics.user_activity (
    event_id, user_id, activity_type, workspace_id, metadata, timestamp
) VALUES
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Chrome"}', now() - INTERVAL 7 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000002', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Safari"}', now() - INTERVAL 6 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000003', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"mobile","browser":"Mobile Safari"}', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'file_upload', '10000000-0000-0000-0000-000000000001', '{"file_type":"pdf","size_mb":1.0}', now() - INTERVAL 4 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000004', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Firefox"}', now() - INTERVAL 4 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000002', 'channel_join', '10000000-0000-0000-0000-000000000001', '{"channel":"engineering"}', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Chrome"}', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000003', 'file_upload', '10000000-0000-0000-0000-000000000001', '{"file_type":"png","size_mb":0.5}', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000002', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"mobile","browser":"Chrome Mobile"}', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000004', 'settings_update', '10000000-0000-0000-0000-000000000001', '{"field":"notifications"}', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Chrome"}', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000003', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Chrome"}', now() - INTERVAL 12 HOUR),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000002', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Safari"}', now() - INTERVAL 6 HOUR),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"desktop","browser":"Chrome"}', now() - INTERVAL 2 HOUR),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000004', 'login', '10000000-0000-0000-0000-000000000001', '{"device":"mobile","browser":"Chrome Mobile"}', now() - INTERVAL 1 HOUR);

-- =============================================================================
-- Search Events (5 entries)
-- =============================================================================
INSERT INTO quckapp_analytics.search_events (
    event_id, user_id, query, workspace_id, results_count, clicked_result_id, timestamp
) VALUES
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'project alpha', '10000000-0000-0000-0000-000000000001', 12, 'm0000000-0000-0000-0000-000000000004', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000002', 'design spec', '10000000-0000-0000-0000-000000000001', 5, 'me000000-0000-0000-0000-000000000002', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000003', 'sprint planning', '10000000-0000-0000-0000-000000000001', 8, 'm0000000-0000-0000-0000-000000000007', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000004', 'bug report', '10000000-0000-0000-0000-000000000001', 3, '', now() - INTERVAL 12 HOUR),
    (generateUUIDv4(), '00000000-0000-0000-0000-000000000001', 'API documentation', '10000000-0000-0000-0000-000000000001', 15, '', now() - INTERVAL 2 HOUR);

-- =============================================================================
-- API Metrics (30 entries)
-- =============================================================================
INSERT INTO quckapp_analytics.api_metrics (
    event_id, service_name, endpoint, method, status_code, response_time_ms,
    user_id, timestamp
) VALUES
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 200, 145, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 7 DAY),
    (generateUUIDv4(), 'workspace-service', '/api/workspaces', 'GET', 200, 32, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 7 DAY),
    (generateUUIDv4(), 'channel-service', '/api/channels', 'GET', 200, 28, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 6 DAY),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 200, 132, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 6 DAY),
    (generateUUIDv4(), 'search-service', '/api/search', 'GET', 200, 89, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), 'media-service', '/api/media/upload', 'POST', 201, 1250, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 401, 45, '', now() - INTERVAL 5 DAY),
    (generateUUIDv4(), 'bookmark-service', '/api/bookmarks', 'POST', 201, 67, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 4 DAY),
    (generateUUIDv4(), 'workspace-service', '/api/workspaces/members', 'GET', 200, 41, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 4 DAY),
    (generateUUIDv4(), 'channel-service', '/api/channels/messages', 'GET', 200, 55, '00000000-0000-0000-0000-000000000004', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 200, 138, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), 'reminder-service', '/api/reminders', 'POST', 201, 78, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 3 DAY),
    (generateUUIDv4(), 'search-service', '/api/search', 'GET', 200, 102, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'media-service', '/api/media/upload', 'POST', 201, 980, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'workspace-service', '/api/workspaces', 'GET', 200, 29, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/token/refresh', 'POST', 200, 52, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'channel-service', '/api/channels', 'POST', 201, 95, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'bookmark-service', '/api/bookmarks/user', 'GET', 200, 43, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 200, 141, '00000000-0000-0000-0000-000000000004', now() - INTERVAL 18 HOUR),
    (generateUUIDv4(), 'search-service', '/api/search', 'GET', 200, 76, '00000000-0000-0000-0000-000000000004', now() - INTERVAL 12 HOUR),
    (generateUUIDv4(), 'media-service', '/api/media', 'GET', 200, 35, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 12 HOUR),
    (generateUUIDv4(), 'workspace-service', '/api/workspaces/stats', 'GET', 200, 125, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 6 HOUR),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 200, 128, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 6 HOUR),
    (generateUUIDv4(), 'channel-service', '/api/channels/messages', 'GET', 200, 48, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 3 HOUR),
    (generateUUIDv4(), 'bookmark-service', '/api/bookmarks', 'GET', 200, 38, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 3 HOUR),
    (generateUUIDv4(), 'reminder-service', '/api/reminders/pending', 'GET', 200, 22, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 2 HOUR),
    (generateUUIDv4(), 'media-service', '/api/media/upload', 'POST', 500, 5002, '00000000-0000-0000-0000-000000000004', now() - INTERVAL 1 HOUR),
    (generateUUIDv4(), 'backend-gateway', '/api/auth/login', 'POST', 429, 12, '', now() - INTERVAL 1 HOUR),
    (generateUUIDv4(), 'search-service', '/api/search', 'GET', 200, 95, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 30 MINUTE),
    (generateUUIDv4(), 'workspace-service', '/api/workspaces', 'GET', 200, 31, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 15 MINUTE);

-- =============================================================================
-- File Events (5 entries)
-- =============================================================================
INSERT INTO quckapp_analytics.file_events (
    event_id, event_type, user_id, workspace_id, file_id,
    file_type, file_size_bytes, timestamp
) VALUES
    (generateUUIDv4(), 'upload', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'me000000-0000-0000-0000-000000000001', 'image/jpeg', 245760, now() - INTERVAL 7 DAY),
    (generateUUIDv4(), 'upload', '00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'me000000-0000-0000-0000-000000000002', 'application/pdf', 1048576, now() - INTERVAL 2 DAY),
    (generateUUIDv4(), 'download', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'me000000-0000-0000-0000-000000000002', 'application/pdf', 1048576, now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'upload', '00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'me000000-0000-0000-0000-000000000003', 'image/png', 512000, now() - INTERVAL 1 DAY),
    (generateUUIDv4(), 'download', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'me000000-0000-0000-0000-000000000003', 'image/png', 512000, now() - INTERVAL 6 HOUR);
