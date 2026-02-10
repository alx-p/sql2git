FROM postgres:13.22-bookworm

RUN apt-get update && apt-get install -y mc

RUN mkdir /var/lib/postgresql/git && chown -R postgres:postgres /var/lib/postgresql/git

WORKDIR /var/lib/postgresql/git

COPY ../sql2git.demo_db.sh .