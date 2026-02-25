FROM postgres:16.12-bookworm

RUN mkdir -p /var/lib/postgresql/git && \
    mkdir -p /var/lib/postgresql/git/functions && \
    mkdir -p /var/lib/postgresql/git/tables && \
    apt-get update && \
    apt-get install -y git cron && \
    service cron start

WORKDIR /var/lib/postgresql/git

COPY sql2git.demo_db.sh .

RUN chown -R postgres:postgres . && \
    chown postgres:postgres sql2git.demo_db.sh && \
    chmod +x sql2git.demo_db.sh

USER postgres

RUN cd functions && \
    git init && \
    cd ../tables && \
    git init && \
    (crontab -l 2>/dev/null; echo "*/5 * * * *  /var/lib/postgresql/git/sql2git.demo_db.sh /var/lib/postgresql/git 2>/dev/null") | crontab - && \
    git config --global user.name "sql2git" && \
    git config --global user.email "email@example.com"

USER root