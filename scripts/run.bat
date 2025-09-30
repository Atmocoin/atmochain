\
@echo on
setlocal enabledelayedexpansion

set COMPOSE_FILE="%CD%\docker-compose.yml"

echo ==== STEP 1: docker compose version ====
docker compose version
if errorlevel 1 goto :fail

echo ==== STEP 2: build (no cache) ====
docker compose -f %COMPOSE_FILE% build --no-cache
if errorlevel 1 goto :fail

echo ==== STEP 3: up -d ====
docker compose -f %COMPOSE_FILE% up -d
if errorlevel 1 goto :fail

echo ==== STEP 4: status ====
docker compose -f %COMPOSE_FILE% ps
if errorlevel 1 goto :fail

echo ==== STEP 5: show last minute logs ====
docker compose -f %COMPOSE_FILE% logs --since=1m > compose_last_minute.log 2>&1
type compose_last_minute.log

echo ==== ALL GOOD ====
pause
exit /b 0

:fail
echo ==== ERROR OCCURRED ====
echo Код ошибки: %errorlevel%
echo Полный лог за последнюю минуту сохранен в compose_last_minute.log
type compose_last_minute.log
pause
exit /b %errorlevel%
