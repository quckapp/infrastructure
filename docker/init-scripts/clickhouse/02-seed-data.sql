-- =============================================================================
-- QuckApp ClickHouse Seed Data
-- =============================================================================

INSERT INTO quckapp_analytics.message_events (event_id, user_id, channel_id, workspace_id, event_type, message_length, has_media, created_at) VALUES
('evt-001', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'sent', 128, 0, now() - INTERVAL 1 HOUR),
('evt-002', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'sent', 256, 0, now() - INTERVAL 2 HOUR),
('evt-003', '00000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'sent', 64, 1, now() - INTERVAL 3 HOUR),
('evt-004', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'edited', 140, 0, now() - INTERVAL 4 HOUR),
('evt-005', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'sent', 512, 0, now() - INTERVAL 1 DAY),
('evt-006', '00000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'sent', 32, 0, now() - INTERVAL 2 DAY),
('evt-007', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'sent', 200, 1, now() - INTERVAL 3 DAY),
('evt-008', '00000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'deleted', 0, 0, now() - INTERVAL 4 DAY),
('evt-009', '00000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'sent', 180, 0, now() - INTERVAL 5 DAY),
('evt-010', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'sent', 95, 0, now() - INTERVAL 6 DAY);

INSERT INTO quckapp_analytics.user_activity (user_id, activity_type, resource_type, resource_id, metadata, created_at) VALUES
('00000000-0000-0000-0000-000000000001', 'login', 'auth', 'session-001', '{"method":"password"}', now() - INTERVAL 1 HOUR),
('00000000-0000-0000-0000-000000000002', 'page_view', 'workspace', '10000000-0000-0000-0000-000000000001', '{"page":"channels"}', now() - INTERVAL 2 HOUR),
('00000000-0000-0000-0000-000000000003', 'file_upload', 'media', 'file-001', '{"size":2048576}', now() - INTERVAL 3 HOUR),
('00000000-0000-0000-0000-000000000001', 'settings_change', 'user', '00000000-0000-0000-0000-000000000001', '{"field":"theme"}', now() - INTERVAL 1 DAY),
('00000000-0000-0000-0000-000000000004', 'login', 'auth', 'session-002', '{"method":"oauth"}', now() - INTERVAL 2 DAY);

INSERT INTO quckapp_analytics.search_events (user_id, query, result_count, clicked_result, search_type, latency_ms, created_at) VALUES
('00000000-0000-0000-0000-000000000001', 'deployment guide', 5, 1, 'messages', 45, now() - INTERVAL 1 HOUR),
('00000000-0000-0000-0000-000000000002', 'bug fix', 12, 1, 'messages', 38, now() - INTERVAL 1 DAY),
('00000000-0000-0000-0000-000000000003', 'design mockup', 3, 0, 'files', 52, now() - INTERVAL 2 DAY),
('00000000-0000-0000-0000-000000000001', 'alice', 2, 1, 'users', 15, now() - INTERVAL 3 DAY),
('00000000-0000-0000-0000-000000000004', 'meeting notes', 8, 1, 'files', 41, now() - INTERVAL 4 DAY);

INSERT INTO quckapp_analytics.api_metrics (service, endpoint, method, status_code, latency_ms, request_size, response_size, user_id, created_at) VALUES
('backend-gateway', '/api/auth/login', 'POST', 200, 120, 256, 512, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 1 MINUTE),
('workspace-service', '/api/workspaces', 'GET', 200, 45, 0, 1024, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 2 MINUTE),
('channel-service', '/api/channels', 'GET', 200, 38, 0, 2048, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 3 MINUTE),
('message-service', '/api/messages', 'POST', 201, 65, 512, 256, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 5 MINUTE),
('search-service', '/api/search', 'GET', 200, 150, 128, 4096, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 10 MINUTE),
('media-service', '/api/upload', 'POST', 201, 850, 2048576, 128, '00000000-0000-0000-0000-000000000003', now() - INTERVAL 15 MINUTE),
('auth-service', '/api/auth/login', 'POST', 401, 30, 256, 64, '', now() - INTERVAL 20 MINUTE),
('backend-gateway', '/api/users/me', 'GET', 200, 25, 0, 512, '00000000-0000-0000-0000-000000000001', now() - INTERVAL 30 MINUTE),
('notification-service', '/api/notifications', 'GET', 200, 55, 0, 1536, '00000000-0000-0000-0000-000000000004', now() - INTERVAL 1 HOUR),
('bookmark-service', '/api/bookmarks', 'POST', 201, 42, 256, 128, '00000000-0000-0000-0000-000000000002', now() - INTERVAL 2 HOUR);

INSERT INTO quckapp_analytics.file_events (file_id, user_id, event_type, file_size, mime_type, created_at) VALUES
('file-001', '00000000-0000-0000-0000-000000000003', 'upload', 2048576, 'image/png', now() - INTERVAL 3 HOUR),
('file-002', '00000000-0000-0000-0000-000000000001', 'upload', 524288, 'application/pdf', now() - INTERVAL 1 DAY),
('file-001', '00000000-0000-0000-0000-000000000002', 'download', 2048576, 'image/png', now() - INTERVAL 2 DAY),
('file-003', '00000000-0000-0000-0000-000000000002', 'upload', 15728640, 'video/mp4', now() - INTERVAL 3 DAY),
('file-002', '00000000-0000-0000-0000-000000000004', 'download', 524288, 'application/pdf', now() - INTERVAL 4 DAY);
