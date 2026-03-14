FROM postgres:16.12-bookworm

RUN mkdir -p /var/lib/postgresql/git && \
    mkdir -p /var/lib/postgresql/git/functions && \
    mkdir -p /var/lib/postgresql/git/tables && \
    apt-get update && \
    apt-get install -y git cron && \
    service cron start

WORKDIR /var/lib/postgresql/git

COPY sql2git.demo_db.sh sql2git.del.sh .

COPY gitschema.sql demo-schema.sql ../

RUN chown -R postgres:postgres . && \
    chown postgres:postgres sql2git.demo_db.sh && \
    chmod +x sql2git.demo_db.sh

USER postgres

RUN cd functions && \
    git init && \
    cd ../tables && \
    git init && \
    (crontab -l 2>/dev/null; echo "*/5 * * * *  /var/lib/postgresql/git/sql2git.demo_db.sh /var/lib/postgresql/git sql2git_demo_db 2>/dev/null") | crontab - && \
    (crontab -l 2>/dev/null; echo "30 00 * * 0  /var/lib/postgresql/git/sql2git.del.sh 2>/dev/null") | crontab - && \
    #(crontab -l 2>/dev/null; echo "30 00 * * 0  cd /var/lib/postgresql/git/functions/ && /bin/find . -type f -name '*.sql' -mtime +7 -exec /usr/bin/git rm {} \;") | crontab - && \
    #(crontab -l 2>/dev/null; echo "35 00 * * 0  cd /var/lib/postgresql/git/tables/ && /bin/find . -type f -name '*.sql' -mtime +7 -exec /usr/bin/git rm {} \;") | crontab - && \
    git config --global user.name "sql2git" && \
    git config --global user.email "email@example.com"

WORKDIR /var/lib/postgresql
USER root