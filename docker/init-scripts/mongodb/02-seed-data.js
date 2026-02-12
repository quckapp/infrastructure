// =============================================================================
// QuckApp MongoDB Seed Data
// =============================================================================

db = db.getSiblingDB('quckapp');

// Audit Logs
db.audit_logs.insertMany([
  { userId: '00000000-0000-0000-0000-000000000001', action: 'user.login', resource: 'auth', resourceId: '00000000-0000-0000-0000-000000000001', ip: '192.168.1.100', userAgent: 'Mozilla/5.0', metadata: { method: 'password' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000001', action: 'workspace.create', resource: 'workspace', resourceId: '10000000-0000-0000-0000-000000000001', metadata: { name: 'QuckApp Dev' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000001', action: 'channel.create', resource: 'channel', resourceId: '30000000-0000-0000-0000-000000000001', metadata: { name: 'general', workspaceId: '10000000-0000-0000-0000-000000000001' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000002', action: 'user.login', resource: 'auth', resourceId: '00000000-0000-0000-0000-000000000002', ip: '192.168.1.101', metadata: { method: 'password' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000001', action: 'settings.update', resource: 'workspace', resourceId: '10000000-0000-0000-0000-000000000001', metadata: { field: 'description' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000003', action: 'user.login', resource: 'auth', resourceId: '00000000-0000-0000-0000-000000000003', ip: '10.0.0.50', metadata: { method: 'oauth', provider: 'google' }, createdAt: new Date() },
  { userId: null, action: 'user.login_failed', resource: 'auth', metadata: { email: 'hacker@evil.com', reason: 'invalid_credentials', ip: '203.0.113.50' }, createdAt: new Date() }
]);

// Activity Logs
db.activity_logs.insertMany([
  { userId: '00000000-0000-0000-0000-000000000001', type: 'page_view', resource: '/workspace/10000000-0000-0000-0000-000000000001', metadata: { duration: 45000 }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000002', type: 'message_sent', resource: 'channel:30000000-0000-0000-0000-000000000001', metadata: { length: 128 }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000003', type: 'file_upload', resource: 'media:file-001', metadata: { filename: 'design-v2.png', size: 2048576 }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000002', type: 'reaction', resource: 'message:msg-001', metadata: { emoji: 'thumbsup' }, createdAt: new Date() },
  { userId: '00000000-0000-0000-0000-000000000001', type: 'search', resource: 'global', metadata: { query: 'deployment guide', results: 5 }, createdAt: new Date() }
]);

// File Metadata
db.file_metadata.insertMany([
  { fileId: 'file-001', userId: '00000000-0000-0000-0000-000000000003', filename: 'design-v2.png', mimeType: 'image/png', sizeBytes: 2048576, s3Key: 'uploads/2024/01/design-v2.png', s3Bucket: 'quckapp-media-dev', thumbnails: { small: 'thumbs/design-v2-128.png', medium: 'thumbs/design-v2-256.png' }, status: 'ready', createdAt: new Date() },
  { fileId: 'file-002', userId: '00000000-0000-0000-0000-000000000001', filename: 'meeting-notes.pdf', mimeType: 'application/pdf', sizeBytes: 524288, s3Key: 'uploads/2024/01/meeting-notes.pdf', s3Bucket: 'quckapp-media-dev', status: 'ready', createdAt: new Date() },
  { fileId: 'file-003', userId: '00000000-0000-0000-0000-000000000002', filename: 'demo-recording.mp4', mimeType: 'video/mp4', sizeBytes: 15728640, s3Key: 'uploads/2024/01/demo-recording.mp4', s3Bucket: 'quckapp-media-dev', status: 'processing', createdAt: new Date() }
]);

// User Presence
db.user_presence.insertMany([
  { userId: '00000000-0000-0000-0000-000000000001', status: 'online', lastSeen: new Date(), statusText: 'Working on QuckApp', device: 'desktop' },
  { userId: '00000000-0000-0000-0000-000000000002', status: 'away', lastSeen: new Date(Date.now() - 600000), statusText: '', device: 'mobile' },
  { userId: '00000000-0000-0000-0000-000000000003', status: 'online', lastSeen: new Date(), statusText: 'In a meeting', device: 'desktop' },
  { userId: '00000000-0000-0000-0000-000000000004', status: 'offline', lastSeen: new Date(Date.now() - 3600000), statusText: '', device: 'web' },
  { userId: '00000000-0000-0000-0000-000000000005', status: 'online', lastSeen: new Date(), statusText: 'Bot is running', device: 'server' }
]);

print('MongoDB seed data inserted successfully.');
