#!/bin/bash

cd /var/lib/postgresql/git/functions/ || exit 1
find . -type f -name '*.sql' -mtime +7 -exec /usr/bin/git rm {} \;

cd /var/lib/postgresql/git/tables/ || exit 1
find . -type f -name '*.sql' -mtime +7 -exec /usr/bin/git rm {} \;