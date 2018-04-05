CREATE TABLE settings
(
  setting character varying(20),
  value	character varying(50)
);
CREATE TABLE domain
(
  id bigserial PRIMARY KEY,
  name character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
-- Record type tables

CREATE TABLE rectype_a
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(15) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_ns
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_cname
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_soa
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  mname character varying(255) NOT NULL,
  rname character varying(255) NOT NULL,
  serial INTEGER NOT NULL,
  refresh INTEGER NOT NULL,
  retry INTEGER NOT NULL,
  expire INTEGER NOT NULL,
  soattl INTEGER NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_ptr
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_mx
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_txt
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_rp
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_afsdb
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_sig
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_key
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_aaaa
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(39) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_loc
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(100) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_srv
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_naptr
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_kx
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_cert
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_dname
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_apl
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_ds
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_sshfp
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_ipseckey
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_rrsig
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_nsec
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_dnskey
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_dhcid
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_nsec3
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_nsec3param
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_tlsa
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_hip
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_cds
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_cdnskey
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_openpgpkey
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_tkey
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_tsig
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_uri
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_cca
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_ta
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);
CREATE TABLE rectype_dlv
(
  id bigserial PRIMARY KEY,
  fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(512) NOT NULL,
  created timestamp without time zone,
  checked timestamp without time zone,
  deleted timestamp without time zone
);




