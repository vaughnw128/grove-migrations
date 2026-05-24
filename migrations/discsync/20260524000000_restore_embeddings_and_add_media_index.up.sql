-- Restore message embedding metadata beside source messages and add media indexing state.

CREATE TABLE IF NOT EXISTS message_embeddings (
    message_id BIGINT NOT NULL PRIMARY KEY
    REFERENCES messages (id) ON DELETE CASCADE,
    embedded_at TIMESTAMP WITHOUT TIME ZONE,
    model_name TEXT,
    chunk_count INTEGER,
    formatted_text TEXT,
    qdrant_collection TEXT,
    qdrant_point_ids JSONB,
    status TEXT,
    error TEXT,
    content_sha256 TEXT
);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_embedded_at
ON message_embeddings (embedded_at);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_status
ON message_embeddings (status);

CREATE INDEX IF NOT EXISTS ix_message_embeddings_content_sha256
ON message_embeddings (content_sha256);

CREATE INDEX IF NOT EXISTS idx_msg_embed_status_embedded
ON message_embeddings (status, embedded_at);

CREATE TABLE IF NOT EXISTS media_assets (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sha256 TEXT NOT NULL UNIQUE,
    object_key TEXT NOT NULL UNIQUE,
    media_kind TEXT NOT NULL
    CHECK (media_kind IN ('still_image', 'animated_gif')),
    content_type TEXT NOT NULL,
    byte_size BIGINT NOT NULL CHECK (byte_size >= 0),
    width INTEGER NOT NULL CHECK (width > 0),
    height INTEGER NOT NULL CHECK (height > 0),
    frame_count INTEGER NOT NULL DEFAULT 1 CHECK (frame_count > 0),
    duration_ms BIGINT CHECK (duration_ms IS NULL OR duration_ms >= 0),
    loop_count INTEGER CHECK (loop_count IS NULL OR loop_count >= 0),
    phash BIT(64),
    storyboard_phash BIT(64),
    sampled_frame_phashes JSONB,
    fingerprint_version TEXT NOT NULL,
    indexed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_media_assets_phash
ON media_assets (phash);

CREATE INDEX IF NOT EXISTS ix_media_assets_storyboard_phash
ON media_assets (storyboard_phash);

CREATE TABLE IF NOT EXISTS message_media (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages (id) ON DELETE CASCADE,
    asset_id BIGINT REFERENCES media_assets (id) ON DELETE SET NULL,
    source_kind TEXT NOT NULL
    CHECK (source_kind IN ('attachment', 'embed_image', 'embed_thumbnail')),
    source_index INTEGER NOT NULL CHECK (source_index >= 0),
    source_url_fingerprint TEXT,
    status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'unavailable')),
    error TEXT,
    discovered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    indexed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (message_id, source_kind, source_index)
);

CREATE INDEX IF NOT EXISTS ix_message_media_status_discovered
ON message_media (status, discovered_at);

CREATE INDEX IF NOT EXISTS ix_message_media_asset_id
ON message_media (asset_id);
