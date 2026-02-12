FROM postgres:13.22-bookworm

WORKDIR /var/lib/postgresql

# Системные
RUN apt-get update && apt-get install -y git cron mc && service cron start && \
    # mkdir -p /var/lib/postgresql/git/{functions,tables} && \ # почему-то не работает - создает один каталог /{functions,tables}
    mkdir -p git/functions && mkdir -p git/tables && \
    chown -R postgres:postgres git

COPY sql2git.demo_db.sh git

RUN cd git && chmod +x sql2git.demo_db.sh

WORKDIR /var/lib/postgresql/git

USER postgres

RUN cd functions && git init && cd ../tables && git init && \
    (crontab -l 2>/dev/null; echo "*/5 * * * *  /var/lib/postgresql/git/sql2git.demo_db.sh /var/lib/postgresql/git 2>/dev/null") | crontab - && \
    git config --global user.name "sql2git" && \
    git config --global user.email "email@example.com"