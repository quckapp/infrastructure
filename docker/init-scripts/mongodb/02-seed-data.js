// =============================================================================
// QuckApp MongoDB Seed Data (Development)
// =============================================================================
// UUIDs are consistent across all databases
// Runs after 01-init.js which creates collections and indexes
// =============================================================================

db = db.getSiblingDB('quckapp');

// =============================================================================
// Audit Log Seed Data
// =============================================================================
db.audit_logs.insertMany([
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        action: "user.login",
        resource_type: "auth",
        resource_id: "00000000-0000-0000-0000-000000000001",
        details: { ip: "192.168.1.100", device: "Chrome/Windows", method: "email" },
        severity: "info",
        timestamp: new Date(Date.now() - 3600000) // 1 hour ago
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        action: "workspace.create",
        resource_type: "workspace",
        resource_id: "10000000-0000-0000-0000-000000000001",
        details: { name: "QuckApp Dev Workspace", plan: "enterprise" },
        severity: "info",
        timestamp: new Date(Date.now() - 86400000) // 1 day ago
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        action: "channel.create",
        resource_type: "channel",
        resource_id: "30000000-0000-0000-0000-000000000001",
        details: { name: "general", type: "public" },
        severity: "info",
        timestamp: new Date(Date.now() - 86000000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000002",
        action: "user.login",
        resource_type: "auth",
        resource_id: "00000000-0000-0000-0000-000000000002",
        details: { ip: "192.168.1.101", device: "Safari/macOS", method: "email" },
        severity: "info",
        timestamp: new Date(Date.now() - 7200000) // 2 hours ago
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000003",
        action: "user.settings.update",
        resource_type: "user_settings",
        resource_id: "00000000-0000-0000-0000-000000000003",
        details: { changed_fields: ["notification_preferences", "theme"] },
        severity: "info",
        timestamp: new Date(Date.now() - 172800000) // 2 days ago
    },
    {
        _id: ObjectId(),
        user_id: null,
        action: "user.login.failed",
        resource_type: "auth",
        resource_id: null,
        details: { ip: "10.0.0.99", email: "unknown@attacker.com", reason: "invalid_credentials" },
        severity: "warning",
        timestamp: new Date(Date.now() - 43200000) // 12 hours ago
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        action: "workspace.member.invite",
        resource_type: "workspace_member",
        resource_id: "20000000-0000-0000-0000-000000000003",
        details: { invited_user_id: "00000000-0000-0000-0000-000000000003", role: "admin" },
        severity: "info",
        timestamp: new Date(Date.now() - 259200000) // 3 days ago
    }
]);

// =============================================================================
// Activity Log Seed Data
// =============================================================================
db.activity_logs.insertMany([
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        activity_type: "page_view",
        metadata: { page: "/workspace/quckapp-dev/channels/general", duration_ms: 45000 },
        timestamp: new Date(Date.now() - 1800000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000002",
        activity_type: "message_sent",
        metadata: { channel_id: "30000000-0000-0000-0000-000000000001", message_type: "text" },
        timestamp: new Date(Date.now() - 3600000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000003",
        activity_type: "file_upload",
        metadata: { file_type: "pdf", size_bytes: 1048576, workspace_id: "10000000-0000-0000-0000-000000000001" },
        timestamp: new Date(Date.now() - 172800000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000004",
        activity_type: "reaction_added",
        metadata: { emoji: "thumbsup", message_id: "m0000000-0000-0000-0000-000000000005" },
        timestamp: new Date(Date.now() - 7200000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        activity_type: "search",
        metadata: { query: "project alpha design", results_count: 12 },
        timestamp: new Date(Date.now() - 5400000)
    }
]);

// =============================================================================
// File Metadata Seed Data
// =============================================================================
db.file_metadata.insertMany([
    {
        _id: ObjectId(),
        file_id: "me000000-0000-0000-0000-000000000001",
        user_id: "00000000-0000-0000-0000-000000000001",
        workspace_id: "10000000-0000-0000-0000-000000000001",
        filename: "avatar_admin.jpg",
        original_filename: "profile_photo.jpg",
        mime_type: "image/jpeg",
        size_bytes: 245760,
        s3_key: "avatars/00000000-0000-0000-0000-000000000001/avatar.jpg",
        s3_bucket: "quckapp-media-dev",
        status: "ready",
        metadata: { width: 400, height: 400, format: "jpeg" },
        created_at: new Date(Date.now() - 604800000) // 7 days ago
    },
    {
        _id: ObjectId(),
        file_id: "me000000-0000-0000-0000-000000000002",
        user_id: "00000000-0000-0000-0000-000000000003",
        workspace_id: "10000000-0000-0000-0000-000000000001",
        filename: "design_spec.pdf",
        original_filename: "Project Alpha Design Spec.pdf",
        mime_type: "application/pdf",
        size_bytes: 1048576,
        s3_key: "documents/design_spec_v1.pdf",
        s3_bucket: "quckapp-media-dev",
        status: "ready",
        metadata: { pages: 24, author: "Alice Johnson" },
        created_at: new Date(Date.now() - 172800000) // 2 days ago
    },
    {
        _id: ObjectId(),
        file_id: "me000000-0000-0000-0000-000000000003",
        user_id: "00000000-0000-0000-0000-000000000002",
        workspace_id: "10000000-0000-0000-0000-000000000001",
        filename: "screenshot.png",
        original_filename: "bug_screenshot.png",
        mime_type: "image/png",
        size_bytes: 512000,
        s3_key: "uploads/screenshot_20240101.png",
        s3_bucket: "quckapp-media-dev",
        status: "ready",
        metadata: { width: 1920, height: 1080, format: "png" },
        created_at: new Date(Date.now() - 86400000) // 1 day ago
    }
]);

// =============================================================================
// User Presence Seed Data (for presence-service)
// =============================================================================
if (!db.getCollectionNames().includes('user_presence')) {
    db.createCollection('user_presence');
}

db.user_presence.insertMany([
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000001",
        status: "online",
        custom_status: "Working on QuckApp",
        custom_emoji: ":computer:",
        last_seen_at: new Date(),
        device: "desktop",
        updated_at: new Date()
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000002",
        status: "away",
        custom_status: "In a meeting",
        custom_emoji: ":calendar:",
        last_seen_at: new Date(Date.now() - 900000), // 15 min ago
        device: "desktop",
        updated_at: new Date(Date.now() - 900000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000003",
        status: "online",
        custom_status: "",
        custom_emoji: null,
        last_seen_at: new Date(Date.now() - 60000), // 1 min ago
        device: "mobile",
        updated_at: new Date(Date.now() - 60000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000004",
        status: "offline",
        custom_status: "",
        custom_emoji: null,
        last_seen_at: new Date(Date.now() - 7200000), // 2 hours ago
        device: "desktop",
        updated_at: new Date(Date.now() - 7200000)
    },
    {
        _id: ObjectId(),
        user_id: "00000000-0000-0000-0000-000000000005",
        status: "online",
        custom_status: "Always here to help!",
        custom_emoji: ":robot:",
        last_seen_at: new Date(),
        device: "server",
        updated_at: new Date()
    }
]);

print('MongoDB seed data loaded successfully!');
