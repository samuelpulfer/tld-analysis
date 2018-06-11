CREATE TABLE recordflat
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  name character varying(255) NOT NULL,
  rectype character varying(10),
  ttl INTEGER NOT NULL,
  value character varying(1024) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);

CREATE TABLE dnsrecord
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  rectype character varying(10),
  ttl INTEGER NOT NULL,
  value character varying(1024) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE dnsdiff
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  name character varying(255) NOT NULL,
  rectype character varying(10),
  ttl INTEGER NOT NULL,
  value character varying(1024) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);

CREATE INDEX i_recordflat
  ON public.recordflat
  USING btree
  (name COLLATE pg_catalog."default");
