-- Number of Records
SELECT COUNT(*) FROM dnsdiff WHERE deleted IS NULL; -- 10394910

-- Number of Domains
SELECT COUNT(s.name) FROM (SELECT DISTINCT name FROM dnsdiff WHERE deleted IS NULL) AS s; -- 1827441

-- RecType with count
SELECT COUNT(id), rectype FROM dnsdiff WHERE deleted IS NULL GROUP BY rectype ORDER BY rectype;

--count  | rectype 
-----------+---------
--   20001 | a
--     706 | aaaa
--       2 | dnskey
-- 1328153 | ds
-- 4566305 | ns
-- 1807511 | nsec
--       8 | rp
-- 2672211 | rrsig
--       1 | soa
--       1 | srv
--      11 | txt

-- state at time x
Select count(*) from dnsdiff where created <= '2018-04-15 02:00:01' AND (deleted IS NULL OR deleted > '2018-04-15 02:00:01');

-- number of domains at time x
SELECT COUNT(s.name) FROM (SELECT DISTINCT name FROM dnsdiff WHERE created <= '2018-04-15 02:00:01' AND (deleted IS NULL OR deleted > '2018-04-15 02:00:01')) AS s;


-- RecType with count deleted at time x
SELECT COUNT(id), rectype FROM dnsdiff WHERE deleted ='2018-04-15 02:00:01' GROUP BY rectype ORDER BY rectype; 

-- RecType with count created at time x
SELECT COUNT(id), rectype FROM dnsdiff WHERE created ='2018-04-15 02:00:01' GROUP BY rectype ORDER BY rectype;


-- New Domains
SELECT COUNT(s.name) FROM (SELECT DISTINCT name FROM dnsdiff WHERE created >= '2018-04-15 02:00:01') AS s;
