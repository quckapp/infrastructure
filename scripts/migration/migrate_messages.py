"""
Migrate messages from MongoDB to ScyllaDB.

Reads from the MongoDB `messages` collection and writes into ScyllaDB tables:
  - messages            (main messages table)
  - message_reactions   (per-message reactions)
  - read_receipts       (last-read position per user per conversation)
  - delivery_receipts   (per-message delivery confirmations)
  - messages_by_sender  (secondary index by sender)

Usage:
    python migrate_messages.py \
        --mongo-uri "mongodb://admin:admin_secret@localhost:27017/quckapp?authSource=admin" \
        --scylla-hosts localhost \
        --scylla-keyspace quckapp \
        --batch-size 1000 \
        --verify
"""

import argparse
import json
import logging
import sys
import uuid
from datetime import datetime, timezone

from bson import ObjectId
from cassandra.cluster import Cluster
from cassandra.query import BatchStatement, BatchType, SimpleStatement
from pymongo import MongoClient

# Stable namespace UUID for deterministic ObjectId -> UUID conversion.
NAMESPACE_QUCKAPP = uuid.UUID("a1b2c3d4-e5f6-7890-abcd-ef1234567890")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def objectid_to_uuid(oid):
    """Convert a MongoDB ObjectId to a deterministic UUID v5."""
    return uuid.uuid5(NAMESPACE_QUCKAPP, str(oid))


def to_timestamp(value):
    """Normalise a datetime-like value to a timezone-aware datetime or None."""
    if value is None:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value
    return None


def safe_set(values):
    """Return a set suitable for a ScyllaDB SET column, or None if empty."""
    if not values:
        return None
    return set(values)


def serialize_attachments(attachments):
    """Serialize the attachments array to a JSON string for ScyllaDB."""
    if not attachments:
        return None
    cleaned = []
    for att in attachments:
        cleaned.append({
            "id": str(att.get("id", "")),
            "file_type": att.get("file_type", ""),
            "file_name": att.get("file_name", ""),
            "file_size": att.get("file_size", 0),
            "url": att.get("url", ""),
            "thumbnail_url": att.get("thumbnail_url", ""),
        })
    return json.dumps(cleaned)


def serialize_edit_history(history):
    """Serialize the edit_history array to a JSON string for ScyllaDB."""
    if not history:
        return None
    cleaned = []
    for entry in history:
        edited_at = entry.get("edited_at")
        cleaned.append({
            "content": entry.get("content", ""),
            "edited_at": edited_at.isoformat() if isinstance(edited_at, datetime) else str(edited_at or ""),
        })
    return json.dumps(cleaned)


# ---------------------------------------------------------------------------
# Prepared statements
# ---------------------------------------------------------------------------

INSERT_MESSAGE = """
    INSERT INTO messages (
        conversation_id, created_at, message_id, sender_id, type, content,
        reply_to_id, mentions, attachments, is_edited, is_deleted, deleted_by,
        deleted_for, edited_at, edit_history, is_forwarded, client_id, metadata
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"""

INSERT_REACTION = """
    INSERT INTO message_reactions (
        conversation_id, message_id, emoji, user_id, created_at
    ) VALUES (?, ?, ?, ?, ?)
"""

INSERT_READ_RECEIPT = """
    INSERT INTO read_receipts (
        conversation_id, user_id, last_read_at, last_read_msg
    ) VALUES (?, ?, ?, ?)
"""

INSERT_DELIVERY_RECEIPT = """
    INSERT INTO delivery_receipts (
        conversation_id, message_id, user_id, delivered_at
    ) VALUES (?, ?, ?, ?)
"""

INSERT_MESSAGE_BY_SENDER = """
    INSERT INTO messages_by_sender (
        sender_id, created_at, message_id, conversation_id, content
    ) VALUES (?, ?, ?, ?, ?)
"""


# ---------------------------------------------------------------------------
# Core migration logic
# ---------------------------------------------------------------------------

def connect_mongo(uri):
    """Connect to MongoDB and return the database handle."""
    client = MongoClient(uri)
    db = client.get_default_database()
    # Verify connectivity.
    db.command("ping")
    logger.info("Connected to MongoDB database '%s'", db.name)
    return client, db


def connect_scylla(hosts, keyspace):
    """Connect to ScyllaDB and return (cluster, session)."""
    host_list = [h.strip() for h in hosts.split(",")]
    cluster = Cluster(host_list)
    session = cluster.connect(keyspace)
    logger.info("Connected to ScyllaDB keyspace '%s' on %s", keyspace, host_list)
    return cluster, session


def prepare_statements(session):
    """Prepare all CQL statements upfront for performance."""
    return {
        "message": session.prepare(INSERT_MESSAGE),
        "reaction": session.prepare(INSERT_REACTION),
        "read_receipt": session.prepare(INSERT_READ_RECEIPT),
        "delivery_receipt": session.prepare(INSERT_DELIVERY_RECEIPT),
        "message_by_sender": session.prepare(INSERT_MESSAGE_BY_SENDER),
    }


def flush_batch(session, statements, label="batch"):
    """Execute a batch of statements, splitting into sub-batches of 50."""
    if not statements:
        return

    for i in range(0, len(statements), 50):
        chunk = statements[i:i + 50]
        batch = BatchStatement(batch_type=BatchType.UNLOGGED)
        for stmt in chunk:
            batch.add(stmt)
        session.execute(batch)


def migrate_messages(mongo_db, scylla_session, prepared, batch_size):
    """
    Stream messages from MongoDB and write to all ScyllaDB target tables.

    Returns the total number of messages processed.
    """
    collection = mongo_db["messages"]
    total = collection.estimated_document_count()
    logger.info("Estimated %d messages in MongoDB", total)

    # Track the latest read timestamp per (conversation_id, user_id) so we
    # only write the most recent read receipt at the end.
    read_receipt_tracker = {}

    pending_statements = []
    migrated = 0

    cursor = collection.find().sort("_id", 1).batch_size(batch_size)

    for doc in cursor:
        conversation_id = doc.get("conversation_id", "")
        created_at = to_timestamp(doc.get("created_at"))
        message_id = objectid_to_uuid(doc["_id"])
        sender_id = doc.get("sender_id", "")
        msg_type = doc.get("type", "text")
        content = doc.get("content", "")
        reply_to = objectid_to_uuid(doc["reply_to"]) if doc.get("reply_to") else None
        mentions = safe_set(doc.get("mentions"))
        attachments = serialize_attachments(doc.get("attachments"))
        is_edited = bool(doc.get("edited", False))
        is_deleted = bool(doc.get("deleted", False))
        deleted_by = doc.get("deleted_by")
        deleted_for = safe_set(doc.get("deleted_for"))
        edited_at = to_timestamp(doc.get("edited_at"))
        edit_history = serialize_edit_history(doc.get("edit_history"))

        # -- messages table --
        pending_statements.append(prepared["message"].bind((
            conversation_id, created_at, message_id, sender_id, msg_type,
            content, reply_to, mentions, attachments, is_edited, is_deleted,
            deleted_by, deleted_for, edited_at, edit_history,
            False,  # is_forwarded (not present in source)
            None,   # client_id (not present in source)
            None,   # metadata (not present in source)
        )))

        # -- messages_by_sender table --
        pending_statements.append(prepared["message_by_sender"].bind((
            sender_id, created_at, message_id, conversation_id, content,
        )))

        # -- reactions --
        for reaction in doc.get("reactions", []):
            pending_statements.append(prepared["reaction"].bind((
                conversation_id,
                message_id,
                reaction.get("emoji", ""),
                reaction.get("user_id", ""),
                to_timestamp(reaction.get("created_at")),
            )))

        # -- delivery receipts --
        for delivery in doc.get("delivered_to", []):
            pending_statements.append(prepared["delivery_receipt"].bind((
                conversation_id,
                message_id,
                delivery.get("user_id", ""),
                to_timestamp(delivery.get("delivered_at")),
            )))

        # -- read receipts (accumulate latest per user per conversation) --
        for read_entry in doc.get("read_by", []):
            user_id = read_entry.get("user_id", "")
            read_at = to_timestamp(read_entry.get("read_at"))
            if not user_id or read_at is None:
                continue

            key = (conversation_id, user_id)
            existing = read_receipt_tracker.get(key)
            if existing is None or read_at > existing[0]:
                read_receipt_tracker[key] = (read_at, message_id)

        migrated += 1

        # Flush when the pending list gets large enough.
        if len(pending_statements) >= batch_size:
            flush_batch(scylla_session, pending_statements, label=f"messages@{migrated}")
            pending_statements.clear()

        if migrated % 1000 == 0:
            logger.info("Progress: %d / ~%d messages migrated", migrated, total)

    # Flush remaining message/reaction/delivery statements.
    flush_batch(scylla_session, pending_statements, label="messages-final")
    pending_statements.clear()

    # Write aggregated read receipts.
    logger.info("Writing %d read receipts", len(read_receipt_tracker))
    receipt_statements = []
    for (conv_id, user_id), (last_read_at, last_msg_id) in read_receipt_tracker.items():
        receipt_statements.append(prepared["read_receipt"].bind((
            conv_id, user_id, last_read_at, last_msg_id,
        )))
    flush_batch(scylla_session, receipt_statements, label="read-receipts")

    logger.info("Migration complete: %d messages migrated", migrated)
    return migrated


# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

def verify(mongo_db, scylla_session):
    """Compare record counts between MongoDB and ScyllaDB."""
    mongo_count = mongo_db["messages"].estimated_document_count()

    row = scylla_session.execute("SELECT COUNT(*) FROM messages").one()
    scylla_count = row[0] if row else 0

    row = scylla_session.execute("SELECT COUNT(*) FROM message_reactions").one()
    scylla_reactions = row[0] if row else 0

    row = scylla_session.execute("SELECT COUNT(*) FROM read_receipts").one()
    scylla_reads = row[0] if row else 0

    row = scylla_session.execute("SELECT COUNT(*) FROM delivery_receipts").one()
    scylla_deliveries = row[0] if row else 0

    row = scylla_session.execute("SELECT COUNT(*) FROM messages_by_sender").one()
    scylla_by_sender = row[0] if row else 0

    logger.info("--- Verification ---")
    logger.info("MongoDB messages           : %d", mongo_count)
    logger.info("ScyllaDB messages          : %d", scylla_count)
    logger.info("ScyllaDB messages_by_sender: %d", scylla_by_sender)
    logger.info("ScyllaDB message_reactions : %d", scylla_reactions)
    logger.info("ScyllaDB read_receipts     : %d", scylla_reads)
    logger.info("ScyllaDB delivery_receipts : %d", scylla_deliveries)

    if mongo_count == scylla_count == scylla_by_sender:
        logger.info("Message counts MATCH")
    else:
        logger.warning(
            "Message count MISMATCH: MongoDB=%d, ScyllaDB messages=%d, messages_by_sender=%d",
            mongo_count, scylla_count, scylla_by_sender,
        )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Migrate messages from MongoDB to ScyllaDB",
    )
    parser.add_argument(
        "--mongo-uri",
        default="mongodb://admin:admin_secret@localhost:27017/quckapp?authSource=admin",
        help="MongoDB connection URI (default: %(default)s)",
    )
    parser.add_argument(
        "--scylla-hosts",
        default="localhost",
        help="Comma-separated ScyllaDB contact points (default: %(default)s)",
    )
    parser.add_argument(
        "--scylla-keyspace",
        default="quckapp",
        help="ScyllaDB keyspace (default: %(default)s)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=1000,
        help="Number of MongoDB documents to buffer before flushing (default: %(default)s)",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="After migration, compare record counts in both databases",
    )
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    logger.info("Starting message migration")
    logger.info("  MongoDB URI   : %s", args.mongo_uri)
    logger.info("  ScyllaDB hosts: %s", args.scylla_hosts)
    logger.info("  Keyspace      : %s", args.scylla_keyspace)
    logger.info("  Batch size    : %d", args.batch_size)

    mongo_client = None
    scylla_cluster = None

    try:
        mongo_client, mongo_db = connect_mongo(args.mongo_uri)
        scylla_cluster, scylla_session = connect_scylla(args.scylla_hosts, args.scylla_keyspace)

        prepared = prepare_statements(scylla_session)
        migrated = migrate_messages(mongo_db, scylla_session, prepared, args.batch_size)

        if args.verify:
            verify(mongo_db, scylla_session)

        logger.info("Done. %d messages migrated successfully.", migrated)
    except KeyboardInterrupt:
        logger.warning("Migration interrupted by user")
        sys.exit(1)
    except Exception:
        logger.exception("Migration failed")
        sys.exit(1)
    finally:
        if mongo_client is not None:
            mongo_client.close()
        if scylla_cluster is not None:
            scylla_cluster.shutdown()


if __name__ == "__main__":
    main()
