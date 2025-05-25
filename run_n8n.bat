@echo off
REM =============================================
REM n8n Docker Launcher (Windows)
REM Version: 1.0
REM Docs: https://docs.n8n.io/hosting/docker/
REM =============================================

REM Проверяем, запущен ли Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Docker не установлен или не добавлен в PATH.
    echo Установите Docker Desktop: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM Проверяем, не запущен ли уже n8n
docker ps --filter "name=n8n" --format "{{.Names}}" | findstr /i "n8n" >nul
if %errorlevel% == 0 (
    echo [ВНИМАНИЕ] Контейнер n8n уже запущен!
    echo Остановите его командой: docker stop n8n
    pause
    exit /b 1
)

echo.
echo Запуск n8n в Docker...
echo Порт: 5678
echo URL после запуска: http://localhost:5678
echo.

REM Основная команда запуска
docker run -d ^
  --name n8n ^
  -p 5678:5678 ^
  -e N8N_HOST=0.0.0.0 ^
  -e N8N_PORT=5678 ^
  -e N8N_DIAGNOSTICS_ENABLED=false ^
  -e N8N_RUNNERS_ENABLED=true ^
  -v n8n_data:/home/node/.n8n ^
  n8nio/n8n

REM Проверяем статус
timeout /t 3 >nul
docker ps --filter "name=n8n" --format "{{.Status}}"

echo.
echo =============================================
echo [УСПЕХ] n8n запущен!
echo Доступ: http://localhost:5678
echo.
echo [ПРИМЕЧАНИЯ]
echo 1. Для остановки: docker stop n8n
echo 2. Для просмотра логов: docker logs -f n8n
echo 3. Данные сохраняются в volume 'n8n_data'
echo 4. Настройки: редактируйте переменные в этом .bat-файле
echo =============================================
pause