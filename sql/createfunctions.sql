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
        UPDATE domain SET checked = aTimestamp WHERE name = aName AND deleted IS NULL RETURNING id INTO return_id;
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

-- RECTYPE A
CREATE OR REPLACE FUNCTION public.upsert_a(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_a SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_a (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_a (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE NS
CREATE OR REPLACE FUNCTION public.upsert_ns(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_ns SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_ns (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_ns (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE CNAME
CREATE OR REPLACE FUNCTION public.upsert_cname(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_cname SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_cname (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_cname (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE SOA
CREATE OR REPLACE FUNCTION public.upsert_soa(
	_name character varying,
	_ttl integer,
	_mname character varying,
	_rname character varying,
	_serial integer,
	_refresh integer,
	_retry integer,
	_expire integer,
	_soattl integer,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_soa SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND mname=_mname AND rname=_rname AND serial=_serial AND refresh=_refresh AND retry=_retry AND expire=_expire AND soattl=_soattl AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_soa (fk_domain,ttl,mname,rname,serial,refresh,retry,expire,soattl,created,checked) VALUES (_fk_domain, _ttl, _mname, _rname, _serial, _refresh, _retry, _expire, _soattl, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_soa (fk_domain,ttl,mname,rname,serial,refresh,retry,expire,soattl,created,checked) VALUES (_fk_domain, _ttl, _mname, _rname, _serial, _refresh, _retry, _expire, _soattl, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE PTR
CREATE OR REPLACE FUNCTION public.upsert_ptr(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_ptr SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_ptr (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_ptr (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE MX
CREATE OR REPLACE FUNCTION public.upsert_mx(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_mx SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_mx (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_mx (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE TXT
CREATE OR REPLACE FUNCTION public.upsert_txt(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_txt SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_txt (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_txt (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE RP
CREATE OR REPLACE FUNCTION public.upsert_rp(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_rp SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_rp (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_rp (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE AFSDB
CREATE OR REPLACE FUNCTION public.upsert_afsdb(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_afsdb SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_afsdb (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_afsdb (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE SIG
CREATE OR REPLACE FUNCTION public.upsert_sig(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_sig SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_sig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_sig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE KEY
CREATE OR REPLACE FUNCTION public.upsert_key(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_key SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_key (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_key (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

-- RECTYPE AAAA
CREATE OR REPLACE FUNCTION public.upsert_aaaa(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_aaaa SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_aaaa (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_aaaa (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE LOC
CREATE OR REPLACE FUNCTION public.upsert_loc(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_loc SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_loc (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_loc (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE SRV
CREATE OR REPLACE FUNCTION public.upsert_srv(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_srv SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_srv (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_srv (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE NAPTR
CREATE OR REPLACE FUNCTION public.upsert_naptr(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_naptr SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_naptr (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_naptr (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE KX
CREATE OR REPLACE FUNCTION public.upsert_kx(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_kx SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_kx (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_kx (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE CERT
CREATE OR REPLACE FUNCTION public.upsert_cert(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_cert SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_cert (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_cert (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE DNAME
CREATE OR REPLACE FUNCTION public.upsert_dname(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_dname SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_dname (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_dname (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE APL
CREATE OR REPLACE FUNCTION public.upsert_apl(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_apl SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_apl (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_apl (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE DS
CREATE OR REPLACE FUNCTION public.upsert_ds(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_ds SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_ds (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_ds (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE SSHFP
CREATE OR REPLACE FUNCTION public.upsert_sshfp(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_sshfp SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_sshfp (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_sshfp (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE IPSECKEY
CREATE OR REPLACE FUNCTION public.upsert_ipseckey(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_ipseckey SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_ipseckey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_ipseckey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE RRSIG
CREATE OR REPLACE FUNCTION public.upsert_rrsig(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_rrsig SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_rrsig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_rrsig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE NSEC
CREATE OR REPLACE FUNCTION public.upsert_nsec(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_nsec SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_nsec (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_nsec (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE DNSKEY
CREATE OR REPLACE FUNCTION public.upsert_dnskey(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_dnskey SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_dnskey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_dnskey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE DHCID
CREATE OR REPLACE FUNCTION public.upsert_dhcid(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_dhcid SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_dhcid (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_dhcid (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE NSEC3
CREATE OR REPLACE FUNCTION public.upsert_nsec3(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_nsec3 SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_nsec3 (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_nsec3 (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE NSEC3PARAM
CREATE OR REPLACE FUNCTION public.upsert_nsec3param(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_nsec3param SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_nsec3param (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_nsec3param (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE TLSA
CREATE OR REPLACE FUNCTION public.upsert_tlsa(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_tlsa SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_tlsa (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_tlsa (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE HIP
CREATE OR REPLACE FUNCTION public.upsert_hip(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_hip SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_hip (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_hip (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE CDS
CREATE OR REPLACE FUNCTION public.upsert_cds(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_cds SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_cds (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_cds (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE CDNSKEY
CREATE OR REPLACE FUNCTION public.upsert_cdnskey(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_cdnskey SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_cdnskey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_cdnskey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE OPENPGPKEY
CREATE OR REPLACE FUNCTION public.upsert_openpgpkey(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_openpgpkey SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_openpgpkey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_openpgpkey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE TKEY
CREATE OR REPLACE FUNCTION public.upsert_tkey(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_tkey SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_tkey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_tkey (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE TSIG
CREATE OR REPLACE FUNCTION public.upsert_tsig(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_tsig SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_tsig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_tsig (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE URI
CREATE OR REPLACE FUNCTION public.upsert_uri(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_uri SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_uri (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_uri (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE CCA
CREATE OR REPLACE FUNCTION public.upsert_cca(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_cca SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_cca (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_cca (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE TA
CREATE OR REPLACE FUNCTION public.upsert_ta(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_ta SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_ta (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_ta (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;
  
-- RECTYPE DLV
CREATE OR REPLACE FUNCTION public.upsert_dlv(
	_name character varying,
	_ttl integer,
	_value character varying,
	_timestamp timestamp without time zone)
	RETURNS bigint AS
$$
DECLARE
	_fk_domain BIGINT;
	_id_rec BIGINT;
BEGIN
	-- first try to update domain
	UPDATE domain SET checked = _timestamp WHERE name = _name and deleted IS NULL RETURNING id INTO _fk_domain;
	IF found THEN
		-- try to update rectype
		UPDATE rectype_dlv SET checked = _timestamp WHERE fk_domain=_fk_domain AND ttl=_ttl AND value=_value AND deleted IS NULL RETURNING id INTO _id_rec;
		IF found THEN
			-- if everything is fine return fk_domain
			RETURN _fk_domain;
		END IF;
		-- if not found insert rectype
		INSERT INTO rectype_dlv (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp);
		RETURN _fk_domain;
	END IF;
	-- not there, so try to insert the domain
	INSERT INTO domain (name,created,checked) VALUES (_name, _timestamp, _timestamp) RETURNING id INTO _fk_domain;
	INSERT INTO rectype_dlv (fk_domain,ttl,value,created,checked) VALUES (_fk_domain, _ttl, _value, _timestamp, _timestamp) RETURNING id INTO _id_rec;
	RETURN _fk_domain;
END;
$$
  LANGUAGE plpgsql;

