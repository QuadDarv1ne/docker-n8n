@echo off
SETLOCAL EnableDelayedExpansion
chcp 65001 > nul

REM =============================================
REM n8n Docker Launcher (Windows)
REM Версия: 3.0 с поддержкой .env
REM =============================================

set CONTAINER_NAME=n8n
set DEFAULT_PORT=5678
set ENV_FILE=.env
set LOG_FILE=n8n_docker.log
set TIMESTAMP=%DATE% %TIME%

REM Инициализация переменных из .env
if exist "%ENV_FILE%" (
    echo [%TIMESTAMP%] Обнаружен .env файл, загружаю переменные... >> %LOG_FILE%
    for /f "tokens=1,2 delims==" %%A in (%ENV_FILE%) do (
        set "%%A=%%B"
        echo [%TIMESTAMP%] Загружена переменная: %%A=%%B >> %LOG_FILE%
    )
)

REM Установка порта (из .env или по умолчанию)
if not defined N8N_PORT set N8N_PORT=%DEFAULT_PORT%
if not defined N8N_HOST set N8N_HOST=0.0.0.0

REM Проверка прав администратора
echo [%TIMESTAMP%] Проверка прав администратора... >> %LOG_FILE%
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Скрипт требует запуска от имени администратора >> %LOG_FILE%
    echo.
    echo [ОШИБКА] Скрипт требует запуска от имени администратора
    echo Запустите скрипт через "Запуск от имени администратора"
    pause
    exit /b 1
)

REM Проверка Docker
echo [%TIMESTAMP%] Проверка установки Docker... >> %LOG_FILE%
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Docker не установлен >> %LOG_FILE%
    echo.
    echo [ОШИБКА] Docker не установлен или не добавлен в PATH
    echo Установите Docker Desktop: https://www.docker.com/products/docker-desktop/
    echo Подробности в файле %LOG_FILE%
    pause
    exit /b 1
)

REM Проверка порта
echo [%TIMESTAMP%] Проверка порта %N8N_PORT%... >> %LOG_FILE%
netstat -ano | findstr :%N8N_PORT% >nul
if %errorlevel% == 0 (
    echo [ОШИБКА] Порт %N8N_PORT% занят >> %LOG_FILE%
    echo.
    echo [ОШИБКА] Порт %N8N_PORT% уже используется
    echo Измените порт в файле %ENV_FILE% или освободите порт
    pause
    exit /b 1
)

REM Проверка/остановка существующего контейнера
echo [%TIMESTAMP%] Проверка контейнера %CONTAINER_NAME%... >> %LOG_FILE%
docker ps -a --filter "name=%CONTAINER_NAME%" --format "{{.Names}}" | findstr /i "%CONTAINER_NAME%" >nul
if %errorlevel% == 0 (
    echo [%TIMESTAMP%] Обнаружен существующий контейнер >> %LOG_FILE%
    echo.
    echo Обнаружен существующий контейнер %CONTAINER_NAME%
    echo.
    set /p choice="Остановить и удалить текущий контейнер? [Y/N]: "
    if /i "!choice!"=="Y" (
        echo [%TIMESTAMP%] Остановка контейнера... >> %LOG_FILE%
        docker stop %CONTAINER_NAME% >> %LOG_FILE% 2>&1
        docker rm %CONTAINER_NAME% >> %LOG_FILE% 2>&1
        echo [%TIMESTAMP%] Контейнер удален >> %LOG_FILE%
    ) else (
        exit /b 0
    )
)

REM Запуск контейнера с переменными из .env
echo [%TIMESTAMP%] Запуск контейнера n8n... >> %LOG_FILE%
echo.
echo ============ ПАРАМЕТРЫ ЗАПУСКА ============
echo Имя контейнера: %CONTAINER_NAME%
echo Порт: %N8N_PORT%
echo Хост: %N8N_HOST%
echo Лог-файл: %LOG_FILE%
echo ===========================================
echo.

set "DOCKER_CMD=docker run -d ^
  --name %CONTAINER_NAME% ^
  -p %N8N_PORT%:%N8N_PORT% ^
  -e N8N_HOST=%N8N_HOST% ^
  -e N8N_PORT=%N8N_PORT%"

REM Добавление переменных из .env в команду Docker
if exist "%ENV_FILE%" (
    for /f "tokens=1,2 delims==" %%A in (%ENV_FILE%) do (
        set "DOCKER_CMD=!DOCKER_CMD! -e %%A=%%B"
    )
)

REM Добавление обязательных параметров
set "DOCKER_CMD=!DOCKER_CMD! ^
  -v n8n_data:/home/node/.n8n ^
  --restart unless-stopped ^
  n8nio/n8n:latest"

echo [%TIMESTAMP%] Выполняемая команда: !DOCKER_CMD! >> %LOG_FILE%
cmd /c "!DOCKER_CMD!" >> %LOG_FILE% 2>&1

REM Проверка статуса
timeout /t 5 >nul
docker ps --filter "name=%CONTAINER_NAME%" --format "{{.Status}}" | findstr "Up" >nul

if %errorlevel% neq 0 (
    echo [ОШИБКА] Ошибка запуска контейнера >> %LOG_FILE%
    echo.
    echo [ОШИБКА] Не удалось запустить контейнер
    echo Проверьте логи: %LOG_FILE%
    pause
    exit /b 1
)

echo [%TIMESTAMP%] Контейнер успешно запущен >> %LOG_FILE%
echo.
echo ============ ССЫЛКИ ДОСТУПА =============
echo Веб-интерфейс: http://localhost:%N8N_PORT%
echo.
echo ========== КОМАНДЫ УПРАВЛЕНИЯ ==========
echo Остановить: docker stop %CONTAINER_NAME%
echo Логи: docker logs -f %CONTAINER_NAME%
echo Удалить: docker rm -f %CONTAINER_NAME%
echo =========================================
echo.
pause
