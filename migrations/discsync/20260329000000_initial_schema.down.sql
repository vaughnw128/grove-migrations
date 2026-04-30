-- Rollback for initial_schema.

DROP INDEX IF EXISTS idx_messages_author_id;

DROP INDEX IF EXISTS idx_messages_channel_id_id;

DROP INDEX IF EXISTS idx_messages_channel_id_created;

DROP TABLE IF EXISTS messages;

DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS channels;

DROP TABLE IF EXISTS guilds;
