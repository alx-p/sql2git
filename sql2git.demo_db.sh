#!/bin/bash
#set -x
set -euo pipefail

usage() {
    myname=$(basename "$0")
    echo $1
    echo "Usage: $myname <base_path>"
    echo "Example: $myname /var/lib/postgresql/git"
    exit 1
}

main() {

    if [ "$#" -eq 0 ]; then
        usage "Не переданы параметры"
    fi

    base_path="$1"

    if [[ -z "$base_path" ]]; then
        usage "Указанный параметр пустой"
    fi
    
    local gitbase="${base_path%/}" # Удаляем завершающий слеш, если он есть
    local git_functions="${gitbase}/functions"
    local git_tables="${gitbase}/tables"
    local db_name="sql2git_demo_db"

    # Обработка функций
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
        else
            echo "Error: Can't find '.git' in ${git_functions}" >&2
        fi
    }

    # Обработка таблиц
    process_tables() {
        if [[ -d "${git_tables}/.git" ]]; then
            cd "${git_tables}" || exit 1

            # Получаем список таблиц
            tables=$(psql -tXw -d "$db_name" -c "
                SELECT ns.nspname || '.' || cl.relname
                  FROM pg_class cl
                  JOIN pg_namespace ns ON ns.oid = cl.relnamespace
                  JOIN git.schemas cls ON cls.scheme_name = ns.nspname
                 WHERE cl.relkind = 'r'
            " | sed 's/^[[:space:]]*//')

            # Обрабатываем каждую таблицу
            while IFS= read -r table; do
                local schema="${table%%.*}"
                local name="${table##*.}"

                # Получаем и выполняем команды дампа
                local dump_cmd
                dump_cmd=$(psql -tXw -d "$db_name" -c "
                    SELECT git.get_dump_cmd(p_table_name => '$name', p_schema_name => '$schema', p_mode => 1)
                ")
                eval "$dump_cmd" > "${git_tables}/${table}.sql"

                dump_cmd=$(psql -tXw -d "$db_name" -c "
                    SELECT git.get_dump_cmd(p_table_name => '$name', p_schema_name => '$schema', p_mode => 2)
                ")
                eval "$dump_cmd" >> "${git_tables}/${table}.sql"

                git add "${table}.sql" >/dev/null || true
            done <<< "$tables"

            git commit -a -m "cron backup $(date +'%d.%m.%Y %R')" >/dev/null || true
        else
            echo "Error: Can't find '.git' in ${git_tables}" >&2
        fi
    }

    # Выполняем обработку
    process_functions
    process_tables
}

# Запускаем основную функцию с переданными аргументами
main "$@"