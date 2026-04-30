-- Drop message_embeddings after retiring discsync-embeddings.

DROP INDEX IF EXISTS idx_msg_embed_status_embedded;

DROP INDEX IF EXISTS ix_message_embeddings_content_sha256;

DROP INDEX IF EXISTS ix_message_embeddings_status;

DROP INDEX IF EXISTS ix_message_embeddings_embedded_at;

DROP TABLE IF EXISTS message_embeddings;
