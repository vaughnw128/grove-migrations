-- Restore the original X-API-Key PostgREST auth guard.

DROP FUNCTION IF EXISTS api.check_api_secret();

CREATE FUNCTION api.check_api_secret()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    api_secret text := NULLIF(current_setting('app.settings.api_secret', true), '');
    method text := NULLIF(current_setting('request.method', true), '');
    path text := NULLIF(current_setting('request.path', true), '');
    supplied_secret text := COALESCE(
        NULLIF(current_setting('request.headers', true), ''),
        '{}'
    )::json ->> 'x-api-key';
BEGIN
    IF method IN ('HEAD', 'OPTIONS') OR (method = 'GET' AND path = '/') THEN
        RETURN;
    END IF;

    IF api_secret IS NULL OR supplied_secret IS DISTINCT FROM api_secret THEN
        RAISE EXCEPTION 'Missing or invalid API key'
            USING errcode = 'PT401';
    END IF;
END;
$$;

COMMENT ON FUNCTION api.check_api_secret() IS
$$PostgREST pre-request guard requiring the X-API-Key header.$$;

GRANT EXECUTE ON FUNCTION api.check_api_secret() TO discsync_api;

NOTIFY pgrst, 'reload schema';
