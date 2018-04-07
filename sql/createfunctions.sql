CREATE OR REPLACE FUNCTION public.upsert_domain(
    aname character varying,
    atimestamp timestamp without time zone)
  RETURNS bigint AS
$$
DECLARE
	return_id BIGINT;
BEGIN
 LOOP
        -- first try to update the key
        UPDATE domain SET checked = aTimestamp WHERE name = aName RETURNING id INTO return_id;
        IF found THEN
            RETURN return_id;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO domain (name,created,checked) VALUES (aName, aTimestamp, aTimestamp) RETURNING id INTO return_id;
            RETURN return_id;
        EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;
