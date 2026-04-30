REVOKE EXECUTE ON FUNCTION api.check_api_secret() FROM discsync_api;

REVOKE SELECT ON api.guilds,
api.channels,
api.users,
api.messages
FROM discsync_api;

DROP FUNCTION IF EXISTS api.check_api_secret();
DROP VIEW IF EXISTS api.messages;
DROP VIEW IF EXISTS api.users;
DROP VIEW IF EXISTS api.channels;
DROP VIEW IF EXISTS api.guilds;

REVOKE USAGE ON SCHEMA api FROM discsync_api;
REVOKE discsync_api FROM "discsync-app"; -- noqa: RF05
DROP ROLE IF EXISTS discsync_api;
DROP SCHEMA IF EXISTS api;

NOTIFY pgrst, 'reload schema';
