--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: git; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA git;


ALTER SCHEMA git OWNER TO postgres;

--
-- Name: get_dump_cmd(character varying, character varying, integer); Type: FUNCTION; Schema: git; Owner: postgres
--

CREATE FUNCTION git.get_dump_cmd(p_schema_name character varying, p_table_name character varying, p_mode integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare
  l_tab_name varchar := p_schema_name||'.'||p_table_name;
begin
  case p_mode 
    when 1 then
      return concat_ws(' ', 'pg_dump sql2git_demo_db -s -t', l_tab_name, $$ | sed '/^--.*$/d;/^SET .*$/d;/^SELECT pg_catalog.*$/d;/./,/^$/!d'$$)::varchar;
    when 2 then      
      if exists (select 1 
                   from git.refs
                  where scheme_name = p_schema_name 
                    and table_name = p_table_name) 
      then
        return 'psql sql2git_demo_db -c "select * from '||l_tab_name||' order by 1;"';
      else
        return 'psql sql2git_demo_db -t -c "select null;"';
      end if;
  end case;
exception
  when others then 
    return 'ERROR';
end;
$_$;


ALTER FUNCTION git.get_dump_cmd(p_schema_name character varying, p_table_name character varying, p_mode integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: refs; Type: TABLE; Schema: git; Owner: postgres
--

CREATE TABLE git.refs (
    id integer NOT NULL,
    scheme_name character varying NOT NULL,
    table_name character varying NOT NULL,
    create_date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE git.refs OWNER TO postgres;

--
-- Name: refs_id_seq; Type: SEQUENCE; Schema: git; Owner: postgres
--

CREATE SEQUENCE git.refs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE git.refs_id_seq OWNER TO postgres;

--
-- Name: refs_id_seq; Type: SEQUENCE OWNED BY; Schema: git; Owner: postgres
--

ALTER SEQUENCE git.refs_id_seq OWNED BY git.refs.id;


--
-- Name: schemas; Type: TABLE; Schema: git; Owner: postgres
--

CREATE TABLE git.schemas (
    id integer NOT NULL,
    scheme_name character varying NOT NULL,
    create_date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE git.schemas OWNER TO postgres;

--
-- Name: schemas_id_seq; Type: SEQUENCE; Schema: git; Owner: postgres
--

CREATE SEQUENCE git.schemas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE git.schemas_id_seq OWNER TO postgres;

--
-- Name: schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: git; Owner: postgres
--

ALTER SEQUENCE git.schemas_id_seq OWNED BY git.schemas.id;


--
-- Name: refs id; Type: DEFAULT; Schema: git; Owner: postgres
--

ALTER TABLE ONLY git.refs ALTER COLUMN id SET DEFAULT nextval('git.refs_id_seq'::regclass);


--
-- Name: schemas id; Type: DEFAULT; Schema: git; Owner: postgres
--

ALTER TABLE ONLY git.schemas ALTER COLUMN id SET DEFAULT nextval('git.schemas_id_seq'::regclass);


--
-- Data for Name: refs; Type: TABLE DATA; Schema: git; Owner: postgres
--

COPY git.refs (id, scheme_name, table_name, create_date) FROM stdin;
1	git	schemas	2026-02-05 22:38:36.726709
\.


--
-- Data for Name: schemas; Type: TABLE DATA; Schema: git; Owner: postgres
--

COPY git.schemas (id, scheme_name, create_date) FROM stdin;
1	git	2026-02-05 22:26:18.758152
\.


--
-- Name: refs_id_seq; Type: SEQUENCE SET; Schema: git; Owner: postgres
--

SELECT pg_catalog.setval('git.refs_id_seq', 33, true);


--
-- Name: schemas_id_seq; Type: SEQUENCE SET; Schema: git; Owner: postgres
--

SELECT pg_catalog.setval('git.schemas_id_seq', 33, true);


--
-- Name: refs refs_pk; Type: CONSTRAINT; Schema: git; Owner: postgres
--

ALTER TABLE ONLY git.refs
    ADD CONSTRAINT refs_pk PRIMARY KEY (id);


--
-- Name: schemas schemas_pk; Type: CONSTRAINT; Schema: git; Owner: postgres
--

ALTER TABLE ONLY git.schemas
    ADD CONSTRAINT schemas_pk PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--
