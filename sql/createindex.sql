CREATE INDEX i_domain
  ON public.domain
  USING btree
  (name COLLATE pg_catalog."default");
