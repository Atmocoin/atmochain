@echo on
if not exist .env copy .env.example .env
docker compose build
docker compose up -d
docker compose logs --since=1m > compose_last_minute.log 2>&1
type compose_last_minute.log
pause
