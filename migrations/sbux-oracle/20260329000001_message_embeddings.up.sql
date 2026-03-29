-- Add message_embeddings table for discsync-embeddings.

CREATE TABLE IF NOT EXISTS message_embeddings (
    message_id        BIGINT                      NOT NULL PRIMARY KEY
        REFERENCES messages (id),
    embedded_at       TIMESTAMP WITHOUT TIME ZONE,
    model_name        TEXT,
    chunk_count       INTEGER,
    formatted_text    TEXT,
    qdrant_collection TEXT,
    qdrant_point_ids  JSONB,
    status            TEXT,
    error             TEXT,
    content_sha256    TEXT
);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_embedded_at
    ON message_embeddings (embedded_at);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_status
    ON message_embeddings (status);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_content_sha256
    ON message_embeddings (content_sha256);

CREATE INDEX IF NOT EXISTS idx_msg_embed_status_embedded
    ON message_embeddings (status, embedded_at);
