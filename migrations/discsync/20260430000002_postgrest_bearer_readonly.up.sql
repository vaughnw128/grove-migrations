-- Switch PostgREST API auth to Bearer and enforce read-only methods.

DROP FUNCTION IF EXISTS api.check_api_secret();

CREATE FUNCTION api.check_api_secret()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    api_secret text := NULLIF(current_setting('app.settings.api_secret', true), '');
    method text := NULLIF(current_setting('request.method', true), '');
    path text := NULLIF(current_setting('request.path', true), '');
    auth_header text := COALESCE(
        NULLIF(current_setting('request.headers', true), ''),
        '{}'
    )::json ->> 'authorization';
    supplied_secret text := NULLIF(
        regexp_replace(COALESCE(auth_header, ''), '^Bearer\s+', '', 'i'),
        ''
    );
BEGIN
    IF method IN ('HEAD', 'OPTIONS') OR (method = 'GET' AND path = '/') THEN
        RETURN;
    END IF;

    IF method <> 'GET' THEN
        RAISE EXCEPTION 'Method not allowed'
            USING errcode = 'PT405';
    END IF;

    IF api_secret IS NULL OR supplied_secret IS DISTINCT FROM api_secret THEN
        RAISE EXCEPTION 'Missing or invalid bearer token'
            USING errcode = 'PT401';
    END IF;
END;
$$;

COMMENT ON FUNCTION api.check_api_secret() IS
$$PostgREST pre-request guard requiring Authorization: Bearer for read-only access.$$;

GRANT EXECUTE ON FUNCTION api.check_api_secret() TO discsync_api;

NOTIFY pgrst, 'reload schema';
