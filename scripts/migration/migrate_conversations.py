"""
Migrate conversations from MongoDB to PostgreSQL.

Reads from the MongoDB `conversations` collection (in the backend-gateway
database) and writes into PostgreSQL tables:
  - messaging.conversations  (conversation metadata)
  - messaging.participants   (per-conversation participant rows)

Usage:
    python migrate_conversations.py \
        --mongo-uri "mongodb://admin:admin_secret@localhost:27017/quckapp_gateway?authSource=admin" \
        --mongo-db quckapp_gateway \
        --postgres-uri "postgresql://quckapp:quckapp_secret@localhost:5432/quckapp" \
        --batch-size 500 \
        --verify
"""

import argparse
import json
import logging
import sys
import uuid
from datetime import datetime, timezone
from io import StringIO

import psycopg2
import psycopg2.extras
from pymongo import MongoClient

# Stable namespace UUID for deterministic ObjectId -> UUID conversion.
# Same namespace as the messages migration so cross-references stay consistent.
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
    """Convert a MongoDB ObjectId (or string) to a deterministic UUID v5."""
    return uuid.uuid5(NAMESPACE_QUCKAPP, str(oid))


def to_timestamptz(value):
    """Normalise a datetime-like value to a timezone-aware datetime or None."""
    if value is None:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value
    return None


def safe_str(value, max_len=None):
    """Return a trimmed string or None."""
    if value is None:
        return None
    text = str(value)
    if max_len is not None and len(text) > max_len:
        return text[:max_len]
    return text


# ---------------------------------------------------------------------------
# SQL
# ---------------------------------------------------------------------------

INSERT_CONVERSATION = """
    INSERT INTO messaging.conversations (
        id, type, name, description, avatar_url, created_by,
        is_archived, last_message_at, last_message_preview,
        last_message_sender_id, disappearing_ttl_seconds, metadata,
        created_at, updated_at
    ) VALUES (
        %(id)s, %(type)s, %(name)s, %(description)s, %(avatar_url)s,
        %(created_by)s, %(is_archived)s, %(last_message_at)s,
        %(last_message_preview)s, %(last_message_sender_id)s,
        %(disappearing_ttl_seconds)s, %(metadata)s,
        %(created_at)s, %(updated_at)s
    )
    ON CONFLICT (id) DO NOTHING
"""

INSERT_PARTICIPANT = """
    INSERT INTO messaging.participants (
        conversation_id, user_id, role, nickname, is_muted,
        muted_until, unread_count, last_read_at, joined_at, left_at
    ) VALUES (
        %(conversation_id)s, %(user_id)s, %(role)s, %(nickname)s,
        %(is_muted)s, %(muted_until)s, %(unread_count)s,
        %(last_read_at)s, %(joined_at)s, %(left_at)s
    )
    ON CONFLICT (conversation_id, user_id) DO NOTHING
"""


# ---------------------------------------------------------------------------
# Connections
# ---------------------------------------------------------------------------

def connect_mongo(uri, db_name):
    """Connect to MongoDB and return (client, database)."""
    client = MongoClient(uri)
    db = client[db_name]
    db.command("ping")
    logger.info("Connected to MongoDB database '%s'", db.name)
    return client, db


def connect_postgres(uri):
    """Connect to PostgreSQL and return the connection."""
    conn = psycopg2.connect(uri)
    conn.autocommit = False
    logger.info("Connected to PostgreSQL at %s", uri.split("@")[-1] if "@" in uri else uri)
    return conn


# ---------------------------------------------------------------------------
# Mapping helpers
# ---------------------------------------------------------------------------

def map_conversation(doc):
    """Map a MongoDB conversation document to a dict for the PG INSERT."""
    last_message = doc.get("lastMessage") or {}
    metadata_raw = doc.get("metadata")
    metadata_json = json.dumps(metadata_raw) if metadata_raw else "{}"

    return {
        "id": str(objectid_to_uuid(doc["_id"])),
        "type": safe_str(doc.get("type", "direct"), 20),
        "name": safe_str(doc.get("name"), 255),
        "description": doc.get("description"),
        "avatar_url": doc.get("avatar"),
        "created_by": safe_str(doc.get("creator", ""), 100),
        "is_archived": bool(doc.get("isArchived", False)),
        "last_message_at": to_timestamptz(last_message.get("createdAt")),
        "last_message_preview": safe_str(last_message.get("content")),
        "last_message_sender_id": safe_str(last_message.get("senderId"), 100),
        "disappearing_ttl_seconds": doc.get("disappearingMessagesTimeout"),
        "metadata": metadata_json,
        "created_at": to_timestamptz(doc.get("createdAt")),
        "updated_at": to_timestamptz(doc.get("updatedAt")),
    }


def map_participant(conversation_uuid, participant):
    """Map a MongoDB participant sub-document to a dict for the PG INSERT."""
    user_id = participant.get("userId")
    if user_id is None:
        return None

    return {
        "conversation_id": str(conversation_uuid),
        "user_id": safe_str(user_id, 100),
        "role": safe_str(participant.get("role", "member"), 20),
        "nickname": safe_str(participant.get("nickname"), 100),
        "is_muted": bool(participant.get("isMuted", False)),
        "muted_until": to_timestamptz(participant.get("mutedUntil")),
        "unread_count": int(participant.get("unreadCount", 0)),
        "last_read_at": to_timestamptz(participant.get("lastReadAt")),
        "joined_at": to_timestamptz(participant.get("joinedAt")),
        "left_at": to_timestamptz(participant.get("leftAt")),
    }


# ---------------------------------------------------------------------------
# Batch insert
# ---------------------------------------------------------------------------

def flush_conversations(cursor, conversations, participants):
    """Execute batch inserts for conversations and their participants."""
    if conversations:
        psycopg2.extras.execute_batch(cursor, INSERT_CONVERSATION, conversations, page_size=100)
    if participants:
        psycopg2.extras.execute_batch(cursor, INSERT_PARTICIPANT, participants, page_size=100)


# ---------------------------------------------------------------------------
# Core migration
# ---------------------------------------------------------------------------

def migrate_conversations(mongo_db, pg_conn, batch_size):
    """
    Stream conversations from MongoDB and insert into PostgreSQL.

    Returns the total number of conversations processed.
    """
    collection = mongo_db["conversations"]
    total = collection.estimated_document_count()
    logger.info("Estimated %d conversations in MongoDB", total)

    cursor_pg = pg_conn.cursor()
    migrated = 0
    participants_total = 0

    conv_batch = []
    part_batch = []

    mongo_cursor = collection.find().sort("_id", 1).batch_size(batch_size)

    for doc in mongo_cursor:
        conv_row = map_conversation(doc)
        conv_uuid = conv_row["id"]
        conv_batch.append(conv_row)

        for participant in doc.get("participants", []):
            part_row = map_participant(conv_uuid, participant)
            if part_row is not None:
                part_batch.append(part_row)
                participants_total += 1

        migrated += 1

        if len(conv_batch) >= batch_size:
            flush_conversations(cursor_pg, conv_batch, part_batch)
            pg_conn.commit()
            conv_batch.clear()
            part_batch.clear()

        if migrated % 500 == 0:
            logger.info(
                "Progress: %d / ~%d conversations (%d participants)",
                migrated, total, participants_total,
            )

    # Flush remaining rows.
    if conv_batch or part_batch:
        flush_conversations(cursor_pg, conv_batch, part_batch)
        pg_conn.commit()

    cursor_pg.close()
    logger.info(
        "Migration complete: %d conversations, %d participants",
        migrated, participants_total,
    )
    return migrated, participants_total


# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

def verify(mongo_db, pg_conn):
    """Compare record counts between MongoDB and PostgreSQL."""
    mongo_conv_count = mongo_db["conversations"].estimated_document_count()

    # Count participants across all MongoDB conversations (requires aggregation).
    pipeline = [
        {"$project": {"participant_count": {"$size": {"$ifNull": ["$participants", []]}}}},
        {"$group": {"_id": None, "total": {"$sum": "$participant_count"}}},
    ]
    agg_result = list(mongo_db["conversations"].aggregate(pipeline))
    mongo_part_count = agg_result[0]["total"] if agg_result else 0

    cursor_pg = pg_conn.cursor()

    cursor_pg.execute("SELECT COUNT(*) FROM messaging.conversations")
    pg_conv_count = cursor_pg.fetchone()[0]

    cursor_pg.execute("SELECT COUNT(*) FROM messaging.participants")
    pg_part_count = cursor_pg.fetchone()[0]

    cursor_pg.close()

    logger.info("--- Verification ---")
    logger.info("MongoDB conversations       : %d", mongo_conv_count)
    logger.info("PostgreSQL conversations     : %d", pg_conv_count)
    logger.info("MongoDB total participants   : %d", mongo_part_count)
    logger.info("PostgreSQL total participants: %d", pg_part_count)

    if mongo_conv_count == pg_conv_count:
        logger.info("Conversation counts MATCH")
    else:
        logger.warning(
            "Conversation count MISMATCH: MongoDB=%d, PostgreSQL=%d",
            mongo_conv_count, pg_conv_count,
        )

    if mongo_part_count == pg_part_count:
        logger.info("Participant counts MATCH")
    else:
        logger.warning(
            "Participant count MISMATCH: MongoDB=%d, PostgreSQL=%d",
            mongo_part_count, pg_part_count,
        )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Migrate conversations from MongoDB to PostgreSQL",
    )
    parser.add_argument(
        "--mongo-uri",
        default="mongodb://admin:admin_secret@localhost:27017/quckapp_gateway?authSource=admin",
        help="MongoDB connection URI (default: %(default)s)",
    )
    parser.add_argument(
        "--mongo-db",
        default="quckapp_gateway",
        help="MongoDB database name (default: %(default)s)",
    )
    parser.add_argument(
        "--postgres-uri",
        default="postgresql://quckapp:quckapp_secret@localhost:5432/quckapp",
        help="PostgreSQL connection URI (default: %(default)s)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=500,
        help="Number of conversations to process per batch (default: %(default)s)",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="After migration, compare record counts in both databases",
    )
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    logger.info("Starting conversation migration")
    logger.info("  MongoDB URI    : %s", args.mongo_uri)
    logger.info("  MongoDB DB     : %s", args.mongo_db)
    logger.info("  PostgreSQL URI : %s", args.postgres_uri)
    logger.info("  Batch size     : %d", args.batch_size)

    mongo_client = None
    pg_conn = None

    try:
        mongo_client, mongo_db = connect_mongo(args.mongo_uri, args.mongo_db)
        pg_conn = connect_postgres(args.postgres_uri)

        migrated, participants = migrate_conversations(mongo_db, pg_conn, args.batch_size)

        if args.verify:
            verify(mongo_db, pg_conn)

        logger.info(
            "Done. %d conversations and %d participants migrated successfully.",
            migrated, participants,
        )
    except KeyboardInterrupt:
        logger.warning("Migration interrupted by user")
        sys.exit(1)
    except Exception:
        logger.exception("Migration failed")
        if pg_conn is not None:
            pg_conn.rollback()
        sys.exit(1)
    finally:
        if mongo_client is not None:
            mongo_client.close()
        if pg_conn is not None:
            pg_conn.close()


if __name__ == "__main__":
    main()
