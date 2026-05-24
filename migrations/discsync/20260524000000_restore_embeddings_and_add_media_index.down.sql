-- Remove media indexing state and restored message embedding metadata.

DROP INDEX IF EXISTS ix_message_media_asset_id;

DROP INDEX IF EXISTS ix_message_media_status_discovered;

DROP TABLE IF EXISTS message_media;

DROP INDEX IF EXISTS ix_media_assets_storyboard_phash;

DROP INDEX IF EXISTS ix_media_assets_phash;

DROP TABLE IF EXISTS media_assets;

DROP INDEX IF EXISTS idx_msg_embed_status_embedded;

DROP INDEX IF EXISTS ix_message_embeddings_content_sha256;

DROP INDEX IF EXISTS ix_message_embeddings_status;

DROP INDEX IF EXISTS ix_message_embeddings_embedded_at;

DROP TABLE IF EXISTS message_embeddings;
