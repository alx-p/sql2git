# sql2git
PgToGit

Сохранение метаданных базы данных PostgreSql в Git.

Данный функционал периодически сохраняет объекты базы данных в файлы через pg_dump с последующей фиксацией изменений в этих файлах.

Запуск демо-версии

1. Из каталога с проектом перейдите в каталог с демо
```
cd sql2git-demo
```
2. Скопируйте актуальные файлы в каталог sql2git-demo
```
cp ../gitschema.sql ../sql2git.demo_db.sh .
```
3. Запустите docker compose
```
sudo docker compose up --build
```
4. Загрузите демо-базу в контейнер
```
sudo docker exec -it -u postgres sql2git-demo-pg psql -f demo-schema.sql -d sql2git_demo_db
```
5. Загрузите конфигурационные таблицы в контейнер
```
sudo docker exec -it -u postgres sql2git-demo-pg psql -f gitschema.sql -d sql2git_demo_db
```