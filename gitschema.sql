CREATE SCHEMA git;

CREATE FUNCTION git.get_dump_cmd(p_schema_name character varying, p_table_name character varying, p_mode integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare
  l_tab_name varchar := p_schema_name||'.'||p_table_name;
  l_db_name varchar := (select current_database());
begin
  case p_mode 
    when 1 then
      return concat_ws(' ', 'pg_dump', l_db_name, '-s -t', l_tab_name, $$ | sed '/^--.*$/d;/^SET .*$/d;/^SELECT pg_catalog.*$/d;/./,/^$/!d'$$)::varchar;
    when 2 then      
      if exists (select 1 
                   from git.refs
                  where scheme_name = p_schema_name 
                    and table_name = p_table_name) 
      then
        return 'psql '||l_db_name||' -c "select * from '||l_tab_name||' order by 1;"';
      else
        return 'psql '||l_db_name||' -t -c "select null;"';
      end if;
  end case;
exception
  when others then 
    return 'ERROR';
end;
$_$;

CREATE TABLE git.refs (
    id integer NOT NULL,
    scheme_name character varying NOT NULL,
    table_name character varying NOT NULL,
    create_date timestamp without time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE git.refs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE git.refs_id_seq OWNED BY git.refs.id;

CREATE TABLE git.schemas (
    id integer NOT NULL,
    scheme_name character varying NOT NULL,
    create_date timestamp without time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE git.schemas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE git.schemas_id_seq OWNED BY git.schemas.id;

ALTER TABLE ONLY git.refs ALTER COLUMN id SET DEFAULT nextval('git.refs_id_seq'::regclass);

ALTER TABLE ONLY git.schemas ALTER COLUMN id SET DEFAULT nextval('git.schemas_id_seq'::regclass);

INSERT INTO git.refs (id,scheme_name,table_name,create_date)
VALUES (1,'git','schemas','2026-02-05 22:38:36.726709');

INSERT INTO git.schemas (id,scheme_name,create_date) 
VALUES (1,'git','2026-02-05 22:26:18.758152');

SELECT pg_catalog.setval('git.refs_id_seq', 33, true);

SELECT pg_catalog.setval('git.schemas_id_seq', 33, true);

ALTER TABLE ONLY git.refs
    ADD CONSTRAINT refs_pk PRIMARY KEY (id);

ALTER TABLE ONLY git.schemas
    ADD CONSTRAINT schemas_pk PRIMARY KEY (id);