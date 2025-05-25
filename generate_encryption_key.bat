@echo off
SETLOCAL EnableDelayedExpansion
chcp 65001 > nul

set "ENV_FILE=.env"
set "LOG_FILE=generate_env.log"
set "TIMESTAMP=%DATE% %TIME%"

REM Инициализация лог-файла
echo [%TIMESTAMP%] Начало генерации .env файла > %LOG_FILE%

REM Проверка существующего файла
if exist "%ENV_FILE%" (
    echo [%TIMESTAMP%] Обнаружен существующий .env файл >> %LOG_FILE%
    echo.
    echo [ОШИБКА] Файл .env уже существует!
    echo Для генерации нового сначала удалите существующий.
    echo.
    pause
    exit /b 1
)

REM Генерация безопасного ключа (24 символа)
echo [%TIMESTAMP%] Генерация безопасного ключа >> %LOG_FILE%
set "CHARS=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%%^&*"
set "KEY="
for /L %%i in (1,1,24) do (
    set /a "RND=!RANDOM! %% 72"
    for %%c in (!RND!) do set "KEY=!KEY!!CHARS:~%%c,1!"
)
echo [%TIMESTAMP%] Безопасный ключ сгенерирован >> %LOG_FILE%

REM Генерация пароля (16 символов)
echo [%TIMESTAMP%] Генерация пароля >> %LOG_FILE%
set "PASS_CHARS=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%%^&*"
set "PASS="
for /L %%i in (1,1,16) do (
    set /a "RND=!RANDOM! %% 72"
    for %%c in (!RND!) do set "PASS=!PASS!!PASS_CHARS:~%%c,1!"
)
echo [%TIMESTAMP%] Пароль сгенерирован >> %LOG_FILE%

REM Создание .env файла с комментариями
echo [%TIMESTAMP%] Создание .env файла >> %LOG_FILE%
(
    echo # Основные настройки
    echo N8N_PORT=5678
    echo N8N_HOST=0.0.0.0
    echo N8N_PROTOCOL=http
    echo.
    echo # Безопасность
    echo N8N_BASIC_AUTH_USER=admin
    echo N8N_BASIC_AUTH_PASSWORD=%PASS%
    echo N8N_ENCRYPTION_KEY=%KEY%
    echo.
    echo # Дополнительные настройки
    echo N8N_DIAGNOSTICS_ENABLED=false
    echo N8N_RUNNERS_ENABLED=true
    echo # N8N_WEBHOOK_URL=https://your-domain.com
) > %ENV_FILE%

echo [%TIMESTAMP%] .env файл создан >> %LOG_FILE%

REM Информация для пользователя
echo.
echo ============================================
echo [УСПЕХ] .env файл сгенерирован!
echo
echo Содержимое файла:
echo ============================================
type %ENV_FILE%
echo ============================================
echo.
echo [ВАЖНО] Сохраните этот файл в безопасном месте
echo Лог операции: %LOG_FILE%
echo.

pause
