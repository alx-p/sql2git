#!/bin/bash

usage_message() {
    myname=$(basename "$0")
    echo $1
    echo "Usage: $myname <base_path>"
    echo "Example: $myname /var/lib/postgresql/git"
    exit 1
}

main() {

    if [ "$#" -eq 0 ]; then
        usage_message "Не передан параметр"
    fi

    base_path="$1"

    if [[ -z "$base_path" ]]; then
        usage_message "Указанный параметр <base_path> пустой"
    fi

    gitbase="${base_path%/}" # Удаляем завершающий слеш, если он есть

    cd "${gitbase}/functions" || exit 1
    find . -type f -name '*.sql' -mtime +7 -exec git rm {} \;

    cd "${gitbase}/tables" || exit 1
    find . -type f -name '*.sql' -mtime +7 -exec git rm {} \;

}

main "$@"