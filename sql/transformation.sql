CREATE TEMPORARY TABLE tmp_records(
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

UPDATE recordflat SET fk_domain=s.id
FROM
(SELECT id, name, deleted from domain WHERE name IN (SELECT DISTINCT name FROM recordflat)) as s
WHERE recordflat.name = s.name AND s.deleted IS NULL AND recordflat.created = '2018-04-05 22:46:11';

INSERT INTO domain (name,created,checked) 
SELECT rf.name,rf.created,rf.created FROM recordflat rf WHERE rf.fk_domain IS NULL AND rf.created = '2018-04-05 22:46:11' GROUP BY rf.name,rf.created;


