-- Read-only PostgREST API surface for discsync.

CREATE SCHEMA IF NOT EXISTS api;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'discsync_api') THEN
        CREATE ROLE discsync_api NOLOGIN;
    END IF;
END
$$;

GRANT discsync_api TO "discsync-app"; -- noqa: RF05
GRANT USAGE ON SCHEMA api TO discsync_api;

COMMENT ON SCHEMA api IS
$$Discsync API

Read-only API for archived Discord guilds, channels, users, and messages.$$;

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

CREATE OR REPLACE FUNCTION api.check_api_secret()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    api_secret text := NULLIF(current_setting('app.settings.api_secret', true), '');
    method text := NULLIF(current_setting('request.method', true), '');
    path text := NULLIF(current_setting('request.path', true), '');
    supplied_secret text := COALESCE(NULLIF(current_setting('request.headers', true), ''), '{}')::json ->> 'x-api-key';
BEGIN
    IF method IN ('HEAD', 'OPTIONS') OR (method = 'GET' AND path = '/') THEN
        RETURN;
    END IF;

    IF api_secret IS NULL OR supplied_secret IS DISTINCT FROM api_secret THEN
        RAISE sqlstate 'PT401'
            USING message = 'Missing or invalid API key',
                  detail = 'Send the shared API secret in the X-API-Key header.';
    END IF;
END;
$$;

COMMENT ON FUNCTION api.check_api_secret() IS
'PostgREST pre-request guard requiring the X-API-Key header, while allowing OpenAPI discovery at /.';

GRANT SELECT ON api.guilds,
api.channels,
api.users,
api.messages
TO discsync_api;

GRANT EXECUTE ON FUNCTION api.check_api_secret() TO discsync_api;

NOTIFY pgrst, 'reload schema';
