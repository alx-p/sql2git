FROM postgres:13.22-bookworm

RUN apt-get update && \
    apt-get install -y git cron mc && \
    service cron start && \
    # mkdir -p /var/lib/postgresql/git/{functions,tables} && \ # почему-то не работает - создает один каталог /{functions,tables}
    mkdir -p /var/lib/postgresql/git/functions && \
    mkdir -p /var/lib/postgresql/git/tables && \
    chown -R postgres:postgres /var/lib/postgresql/git && \
    # */5 * * * *  /var/lib/postgresql/git/sql2git.demo_db.sh /opt/postgresql/git 2>/dev/null && \
    git config --global user.name "sql2git" && \
    git config --global user.email "email@example.com" && \
    date

WORKDIR /var/lib/postgresql/git

COPY sql2git.demo_db.sh .