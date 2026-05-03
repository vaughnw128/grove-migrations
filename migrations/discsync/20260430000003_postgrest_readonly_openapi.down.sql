-- Restore simple auto-updatable views from the original PostgREST migration.

CREATE OR REPLACE VIEW api.guilds AS
SELECT
    id,
    name,
    owner_id,
    icon,
    features
FROM guilds;

CREATE OR REPLACE VIEW api.channels AS
SELECT
    id,
    guild_id,
    name,
    kind,
    topic,
    nsfw,
    parent_id,
    position
FROM channels;

CREATE OR REPLACE VIEW api.users AS
SELECT
    id,
    username,
    global_name,
    discriminator,
    avatar,
    bot
FROM users;

CREATE OR REPLACE VIEW api.messages AS
SELECT
    id,
    guild_id,
    channel_id,
    author_id,
    created_at_ms,
    edited_at_ms,
    content,
    tts,
    pinned,
    kind,
    flags,
    mentions,
    attachments,
    embeds,
    components,
    reactions,
    message_reference
FROM messages;

COMMENT ON VIEW api.guilds IS 'Discord guild metadata archived by discsync.';
COMMENT ON VIEW api.channels IS 'Discord channel metadata archived by discsync.';
COMMENT ON VIEW api.users IS 'Discord user metadata archived by discsync.';
COMMENT ON VIEW api.messages IS 'Discord messages archived by discsync, excluding raw_json.';

GRANT SELECT ON api.guilds,
api.channels,
api.users,
api.messages
TO discsync_api;

NOTIFY pgrst, 'reload schema';
