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
