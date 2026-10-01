-- ============================================================
-- 02_staging / 00_date_helpers.sql
-- Helper functions for staging transformations
-- Phase 6 — Data Quality and Cleaning
-- ============================================================

-- ------------------------------------------------------------
-- parse_date(txt text) RETURNS date
-- Parses 4 date formats:
--   YYYY-MM-DD  (ISO)
--   DD/MM/YYYY  (European slash)
--   MM/DD/YYYY  (US slash)
--   DD-MM-YYYY  (European dash)
--   MM-DD-YYYY  (US dash)
-- Returns NULL on failure.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION staging.parse_date(txt text)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    p1 int;
    p2 int;
BEGIN
    IF txt IS NULL OR txt = '' THEN
        RETURN NULL;
    END IF;

    -- ISO format
    IF txt ~ '^\d{4}-\d{2}-\d{2}$' THEN
        BEGIN
            RETURN txt::date;
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END IF;

    -- DD/MM/YYYY or MM/DD/YYYY
    IF txt ~ '^\d{2}/\d{2}/\d{4}$' THEN
        p1 := split_part(txt, '/', 1)::int;
        p2 := split_part(txt, '/', 2)::int;
        BEGIN
            IF p1 > 12 THEN
                RETURN to_date(txt, 'DD/MM/YYYY');
            ELSIF p2 > 12 THEN
                RETURN to_date(txt, 'MM/DD/YYYY');
            ELSE
                RETURN to_date(txt, 'DD/MM/YYYY');  -- ambiguous -> European
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END IF;

    -- DD-MM-YYYY or MM-DD-YYYY
    IF txt ~ '^\d{2}-\d{2}-\d{4}$' THEN
        p1 := split_part(txt, '-', 1)::int;
        p2 := split_part(txt, '-', 2)::int;
        BEGIN
            IF p1 > 12 THEN
                RETURN to_date(txt, 'DD-MM-YYYY');
            ELSIF p2 > 12 THEN
                RETURN to_date(txt, 'MM-DD-YYYY');
            ELSE
                RETURN to_date(txt, 'DD-MM-YYYY');  -- ambiguous -> European
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END IF;

    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION staging.parse_date(text) IS
    'Parse mixed date formats: ISO, DD/MM/YYYY, MM/DD/YYYY, DD-MM-YYYY, MM-DD-YYYY.';
