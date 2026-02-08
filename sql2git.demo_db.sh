#set -x
#!/bin/bash

### Functions

usage()
{
   myname=$(basename $0)
   echo "usage: $myname <base path>"
}

### Main

if [ "$1" == "" ]; then
   usage
   exit 1
else
   gitbase=${1%'/'}
   gitf="${gitbase}/functions"
   gitt="${gitbase}/tables"

   # PostgreSQL functions
   if [ -d "${gitf}/.git" ]; then 
      cd ${gitf}
      for i in $(psql demo_db -tXw -c "select specific_schema||'.'||routine_name from information_schema.routines where specific_schema not in ('pg_catalog','information_schema','tech_docum','temp')"); do
         psql demo_db -tXw -c "SELECT pg_get_functiondef(f.oid) FROM pg_catalog.pg_proc f INNER JOIN pg_catalog.pg_namespace n ON (f.pronamespace = n.oid) WHERE f.proname='${i##*.}' AND n.nspname = '${i%%.*}'" |sed 's/\(\\r\)\?[[:blank:]]*+$//' > ${gitf}/${i}.sql
#         psql demo_db -tXw -c "SELECT '---------- �пи�ание ��нк�ии ----------'||CHR(10)||'/*'||CHR(10)|| ds.description||CHR(10)||'*/' FROM pg_proc p LEFT OUTER JOIN pg_description ds ON ds.objoid = p.oid INNER JOIN pg_namespace n ON p.pronamespace = n.oid WHERE p.proname = '${i##*.}' AND n.nspname = '${i%%.*}'" | sed 's/\(\\r\)\?[[:blank:]]*+$//' >> ${gitf}/${i}.sql
         git add ${i}.sql >/dev/null
      done
      git commit -a -m "cron backup `date +'%d.%m.%Y %R'`" >/dev/null
#      git push -u origin master >/dev/null
   else
      echo "Can't find \".git\" in the ${gitf}"
   fi

   # PostgreSQL tables
   if [ -d "${gitt}/.git" ]; then
      cd ${gitt}
      for i in $(psql demo_db -tXw -c "select ns.nspname||'.'||cl.relname from pg_class cl join pg_namespace ns on ns.oid=cl.relnamespace join git.schemas cls on cls.scheme_name =ns.nspname where cl.relkind='r'"); do
         # psql demo_db -tXw -c "select public.get_table_ddl(p_table_name=>'${i##*.}',p_schema_name=>'${i%%.*}')" | sed 's/\(\\r\)\?[[:blank:]]*+$//' >${gitt}/${i}.sql

         dumpcmd=$(psql demo_db -tXw -c "select git.get_dump_cmd(p_table_name=>'${i##*.}',p_schema_name=>'${i%%.*}',p_mode=>1)")
         eval "$dumpcmd" > ${gitt}/${i}.sql

         dumpcmd=$(psql demo_db -tXw -c "select git.get_dump_cmd(p_table_name=>'${i##*.}',p_schema_name=>'${i%%.*}',p_mode=>2)")
         eval "$dumpcmd" >> ${gitt}/${i}.sql

         git add ${i}.sql >/dev/null
      done
      git commit -a -m "cron backup `date +'%d.%m.%Y %R'`" >/dev/null
#      git push -u origin master >/dev/null
   else
      echo "Can't find \".git\" in the ${gitt}"
   fi
fi
