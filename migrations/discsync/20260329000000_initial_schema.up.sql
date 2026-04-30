-- Initial schema for sbux-oracle.

CREATE TABLE IF NOT EXISTS guilds (
    id BIGINT NOT NULL PRIMARY KEY,
    name TEXT,
    owner_id BIGINT,
    icon TEXT,
    features JSONB,
    raw_json JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS channels (
    id BIGINT NOT NULL PRIMARY KEY,
    guild_id BIGINT,
    name TEXT,
    kind TEXT,
    topic TEXT,
    nsfw BOOLEAN NOT NULL DEFAULT FALSE,
    parent_id BIGINT,
    position INTEGER,
    raw_json JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id BIGINT NOT NULL PRIMARY KEY,
    username TEXT,
    global_name TEXT,
    discriminator TEXT,
    avatar TEXT,
    bot BOOLEAN NOT NULL DEFAULT FALSE,
    raw_json JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS messages (
    id BIGINT NOT NULL PRIMARY KEY,
    guild_id BIGINT,
    channel_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    created_at_ms BIGINT NOT NULL,
    edited_at_ms BIGINT,
    content TEXT,
    tts BOOLEAN NOT NULL DEFAULT FALSE,
    pinned BOOLEAN NOT NULL DEFAULT FALSE,
    kind TEXT,
    flags BIGINT,
    mentions JSONB,
    attachments JSONB,
    embeds JSONB,
    components JSONB,
    reactions JSONB,
    message_reference JSONB,
    raw_json JSONB NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_messages_channel_id_created
ON messages (channel_id, created_at_ms);

CREATE INDEX IF NOT EXISTS idx_messages_channel_id_id
ON messages (channel_id, id);

CREATE INDEX IF NOT EXISTS idx_messages_author_id
ON messages (author_id);
