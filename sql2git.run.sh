#!/bin/bash
#set -x
set -euo pipefail

usage() {
    myname=$(basename "$0")
    echo $1
    echo "Usage: $myname <base_path> <db_name>"
    echo "Example: $myname /var/lib/postgresql/git sql2git_demo_db"
    exit 1
}

main() {

    if [ "$#" -ne 2 ]; then
        usage "Не переданы параметры"
    fi

    base_path="$1"
    db_name="$2"

    if [[ -z "$base_path" ]]; then
        usage "Указанный параметр <base_path> пустой"
    fi

    if [[ -z "$db_name" ]]; then
        usage "Указанный параметр <db_name> пустой"
    fi

    gitbase="${base_path%/}" # Удаляем завершающий слеш, если он есть
    local git_functions="${gitbase}/functions"
    local git_tables="${gitbase}/tables"   

    # Функции
    process_functions() {
        if [[ -d "${git_functions}/.git" ]]; then
            cd "${git_functions}" || exit 1

            # Получаем список функций
            functions=$(psql -tXw -d "$db_name" -c "
                SELECT specific_schema || '.' || routine_name
                  FROM information_schema.routines
                 WHERE specific_schema NOT IN ('pg_catalog', 'information_schema', 'tech_docum', 'temp')
            " | sed 's/^[[:space:]]*//')

            # Обрабатываем каждую функцию
            while IFS= read -r func; do
                local schema="${func%%.*}"
                local name="${func##*.}"

                # Получаем определение функции
                local func_def
                func_def=$(psql -tXw -d "$db_name" -c "
                    SELECT pg_get_functiondef(f.oid)
                      FROM pg_catalog.pg_proc f
                     INNER JOIN pg_catalog.pg_namespace n ON (f.pronamespace = n.oid)
                     WHERE f.proname = '$name' 
                       AND n.nspname = '$schema'
                " | sed 's/[\r]?[[:blank:]]*+$//')

                # Сохраняем в файл
                echo "$func_def" > "${git_functions}/${func}.sql"

                git add "${func}.sql" >/dev/null || true
            done <<< "$functions"

            git commit -a -m "cron backup $(date +'%d.%m.%Y %R')" >/dev/null || true
            # git push -u origin master >/dev/null
        else
            echo "Error: Can't find '.git' in ${git_functions}" >&2
        fi
    }

    # Таблицы
    process_tables() {
        if [[ -d "${git_tables}/.git" ]]; then
            cd "${git_tables}" || exit 1

            psql -tXw -d "$db_name" -c "
                select ns.nspname schema_name,
                       cl.relname table_name,
                       case when r.id is null then 0 else 1 end get_data
                  from pg_class cl
                 inner join pg_namespace ns on ns.oid = cl.relnamespace
                 inner join git.schemas s on s.scheme_name = ns.nspname
                  left join git.refs r on (r.scheme_name, r.table_name) = (ns.nspname, cl.relname)
                 where cl.relkind = 'r'
            " | while IFS='|' read -r schema_name table_name get_data; do

                schema_name=$(echo "$schema_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                table_name=$(echo "$table_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                get_data=$(echo "$get_data" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

                schema_table_name="$schema_name.$table_name"

                # echo "Table: $schema_table_name"
               
                if [ -z "$schema_name" ] && [ -z "$table_name" ]; then
                    continue
                fi

                dump_cmd=$(psql -tXw -d "$db_name" -c "
                    SELECT git.get_dump_cmd(p_table_name => '$table_name', p_schema_name => '$schema_name', p_mode => 1)
                ")
                eval "$dump_cmd" > "${git_tables}/${schema_table_name}.sql"

                dump_cmd=$(psql -tXw -d "$db_name" -c "
                    SELECT git.get_dump_cmd(p_table_name => '$table_name', p_schema_name => '$schema_name', p_mode => 2)
                ")
                eval "$dump_cmd" >> "${git_tables}/${schema_table_name}.sql"

                git add "${schema_table_name}.sql" >/dev/null || true
            
            done

            git commit -a -m "cron backup $(date +'%d.%m.%Y %R')" >/dev/null || true
            #git push -u origin master >/dev/null
        else
            echo "Error: Can't find '.git' in ${git_tables}" >&2
        fi
    }

    process_functions
    process_tables
}

main "$@"