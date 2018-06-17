CREATE INDEX i_diff_created
  ON public.dnsdiff
  USING btree
  (created);
CREATE INDEX i_diff_deleted
  ON public.dnsdiff
  USING btree
  (deleted);
CREATE INDEX i_diff_rectype
  ON public.dnsdiff
  USING btree
  (rectype COLLATE pg_catalog."default");
CREATE INDEX i_diff_name
  ON public.dnsdiff
  USING btree
  (name COLLATE pg_catalog."default");
