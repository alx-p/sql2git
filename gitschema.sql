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
	scheme_name varchar NOT NULL,
	table_name varchar NOT NULL,
	create_date timestamp DEFAULT now() NOT NULL,
	CONSTRAINT refs_pk PRIMARY KEY (scheme_name, table_name)
);

CREATE TABLE git.schemas (
	scheme_name varchar NOT NULL,
	create_date timestamp DEFAULT now() NOT NULL,
	CONSTRAINT schemas_pk PRIMARY KEY (scheme_name)
);

INSERT INTO git.refs (scheme_name,table_name,create_date)
VALUES ('git','schemas','2026-02-05 22:38:36.726709');

INSERT INTO git.schemas (scheme_name,create_date) 
VALUES ('git','2026-02-05 22:26:18.758152');