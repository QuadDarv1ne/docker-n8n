@echo off
SETLOCAL EnableDelayedExpansion
chcp 65001 > nul

:: =============================================
:: n8n Docker Manager (Windows)
:: Версия: 5.0 - полностью переработанный и оптимизированный
:: Автор: Дуплей Максим Игоревич
:: Telegram: @quadd4rv1n7
:: Почта: maksimqwe42@mail.ru
:: =============================================

:: ----------------------------
:: Конфигурация
:: ----------------------------
set "CONTAINER_NAME=n8n"
set "DEFAULT_PORT=5678"
set "ENV_FILE=.env"
set "LOG_FILE=n8n_docker.log"
set "TIMESTAMP=%DATE% %TIME%"
set "DOCKER_IMAGE=n8nio/n8n:latest"

:: Инициализация лог-файла
echo [%TIMESTAMP%] Инициализация скрипта > "%LOG_FILE%"

:: ----------------------------
:: Основной код
:: ----------------------------

:: Проверка прав администратора
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo [%TIMESTAMP%] Ошибка: Требуются права администратора >> "%LOG_FILE%"
    echo.
    echo [ОШИБКА] Запустите скрипт от имени администратора
    pause
    exit /b 1
)

:: Проверка установки Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [%TIMESTAMP%] Ошибка: Docker не установлен >> "%LOG_FILE%"
    echo.
    echo [ОШИБКА] Docker не установлен или не добавлен в PATH
    echo Установите Docker Desktop: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

:: Загрузка переменных из .env файла
if exist "%ENV_FILE%" (
    echo [%TIMESTAMP%] Загрузка переменных из %ENV_FILE% >> "%LOG_FILE%"
    for /f "usebackq tokens=1,2 delims==" %%A in ("%ENV_FILE%") do (
        if not "%%A"=="" (
            if /i not "%%A"=="N8N_BASIC_AUTH_PASSWORD" if /i not "%%A"=="N8N_ENCRYPTION_KEY" (
                echo [%TIMESTAMP%] Загружена переменная: %%A=***** >> "%LOG_FILE%"
            )
            set "%%A=%%B"
        )
    )
    
    :: Установка порта и хоста
    if not defined N8N_PORT set "N8N_PORT=%DEFAULT_PORT%"
    if not defined N8N_HOST set "N8N_HOST=0.0.0.0"
) else (
    set "N8N_PORT=%DEFAULT_PORT%"
    set "N8N_HOST=0.0.0.0"
)

:: Главное меню
:MENU_LOOP
    cls
    echo =============================================
    echo n8n Docker Manager (Windows)
    echo Версия: 5.0
    echo Автор: Дуплей Максим Игоревич
    echo =============================================
    echo.
    
    :: Проверка состояния контейнера
    set "CONTAINER_EXISTS=0"
    set "CONTAINER_RUNNING=0"
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 && (
        set "CONTAINER_EXISTS=1"
        docker inspect --format="{{.State.Running}}" %CONTAINER_NAME% | find "true" >nul && (
            set "CONTAINER_RUNNING=1"
        )
    )
    
    if %CONTAINER_EXISTS% equ 1 (
        echo [Текущий статус]
        if %CONTAINER_RUNNING% equ 1 (
            echo Контейнер %CONTAINER_NAME%: ЗАПУЩЕН
        ) else (
            echo Контейнер %CONTAINER_NAME%: ОСТАНОВЛЕН
        )
        echo.
    )
    
    echo [1] Проверить статус контейнера
    echo [2] Запустить контейнер
    echo [3] Остановить контейнер
    echo [4] Просмотреть логи
    echo [5] Перезапустить контейнер
    echo [6] Удалить контейнер
    echo [7] Выйти
    echo.
    
    set /p "CHOICE=Выберите действие: "
    
    if "%CHOICE%"=="1" (
        call :SHOW_STATUS
    ) else if "%CHOICE%"=="2" (
        call :START_CONTAINER
    ) else if "%CHOICE%"=="3" (
        call :STOP_CONTAINER
    ) else if "%CHOICE%"=="4" (
        call :VIEW_LOGS
    ) else if "%CHOICE%"=="5" (
        call :RESTART_CONTAINER
    ) else if "%CHOICE%"=="6" (
        call :REMOVE_CONTAINER
    ) else if "%CHOICE%"=="7" (
        exit /b 0
    ) else (
        echo Неверный выбор
        pause
    )
    goto MENU_LOOP

:SHOW_STATUS
    cls
    echo ===== Информация о контейнере =====
    echo.
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        echo Контейнер %CONTAINER_NAME% не существует
        pause
        goto :EOF
    )
    
    for /f "tokens=1,2 delims==" %%A in ('docker inspect --format="{{.Config.Image}}={{.State.Status}}" %CONTAINER_NAME% 2^>nul') do (
        echo Образ:        %%A
        echo Статус:       %%B
    )
    
    for /f "tokens=1 delims=" %%P in ('docker inspect --format="{{range .NetworkSettings.Ports}}{{.HostPort}}{{end}}" %CONTAINER_NAME% 2^>nul') do (
        echo Порт:         %%P
    )
    
    for /f "tokens=1 delims=T" %%D in ('docker inspect --format="{{.State.StartedAt}}" %CONTAINER_NAME% 2^>nul') do (
        echo Запущен:      %%D
    )
    
    echo.
    echo ===================================
    pause
    goto :EOF

:START_CONTAINER
    echo [%TIMESTAMP%] Запуск контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        call :CREATE_CONTAINER
        goto :EOF
    )
    
    docker inspect --format="{{.State.Running}}" %CONTAINER_NAME% | find "true" >nul && (
        echo.
        echo Контейнер уже запущен
        pause
        goto :EOF
    )
    
    docker start %CONTAINER_NAME% >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo [%TIMESTAMP%] Ошибка запуска контейнера >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Не удалось запустить контейнер
        pause
        goto :EOF
    )
    
    echo.
    echo Контейнер успешно запущен
    pause
    goto :EOF

:CREATE_CONTAINER
    echo [%TIMESTAMP%] Создание нового контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    
    netstat -ano | findstr ":%N8N_PORT% " >nul && (
        echo [%TIMESTAMP%] Ошибка: Порт %N8N_PORT% занят >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Порт %N8N_PORT% уже используется
        pause
        goto :EOF
    )
    
    set "DOCKER_CMD=docker run -d ^
        --name %CONTAINER_NAME% ^
        -p %N8N_PORT%:%N8N_PORT% ^
        -e N8N_HOST=%N8N_HOST% ^
        -e N8N_PORT=%N8N_PORT%"
    
    if exist "%ENV_FILE%" (
        for /f "usebackq tokens=1,2 delims==" %%A in ("%ENV_FILE%") do (
            if not "%%A"=="" (
                set "DOCKER_CMD=!DOCKER_CMD! -e %%A=%%B"
            )
        )
    )
    
    set "DOCKER_CMD=!DOCKER_CMD! ^
        -v n8n_data:/home/node/.n8n ^
        --restart unless-stopped ^
        %DOCKER_IMAGE%"
    
    echo [%TIMESTAMP%] Выполнение: !DOCKER_CMD! >> "%LOG_FILE%"
    cmd /c "!DOCKER_CMD!" >> "%LOG_FILE%" 2>&1
    
    if %errorlevel% neq 0 (
        echo [%TIMESTAMP%] Ошибка создания контейнера >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Не удалось создать контейнер
        echo Проверьте логи: %LOG_FILE%
        pause
        goto :EOF
    )
    
    timeout /t 5 >nul
    docker inspect --format="{{.State.Running}}" %CONTAINER_NAME% | find "true" >nul || (
        echo [%TIMESTAMP%] Ошибка: Контейнер не запустился >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Контейнер создан, но не запустился
        pause
        goto :EOF
    )
    
    echo.
    echo ============ ССЫЛКИ ДОСТУПА =============
    echo Веб-интерфейс: http://localhost:%N8N_PORT%
    echo.
    echo ========== КОМАНДЫ УПРАВЛЕНИЯ ==========
    echo Остановить: docker stop %CONTAINER_NAME%
    echo Логи: docker logs -f %CONTAINER_NAME%
    echo Удалить: docker rm -f %CONTAINER_NAME%
    echo =========================================
    pause
    goto :EOF

:STOP_CONTAINER
    echo [%TIMESTAMP%] Остановка контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        echo.
        echo Контейнер не существует
        pause
        goto :EOF
    )
    
    docker inspect --format="{{.State.Running}}" %CONTAINER_NAME% | find "false" >nul && (
        echo.
        echo Контейнер уже остановлен
        pause
        goto :EOF
    )
    
    docker stop %CONTAINER_NAME% >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo [%TIMESTAMP%] Ошибка остановки контейнера >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Не удалось остановить контейнер
        pause
        goto :EOF
    )
    
    echo.
    echo Контейнер успешно остановлен
    pause
    goto :EOF

:RESTART_CONTAINER
    echo [%TIMESTAMP%] Перезапуск контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        echo.
        echo Контейнер не существует
        pause
        goto :EOF
    )
    
    docker restart %CONTAINER_NAME% >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo [%TIMESTAMP%] Ошибка перезапуска контейнера >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Не удалось перезапустить контейнер
        pause
        goto :EOF
    )
    
    echo.
    echo Контейнер успешно перезапущен
    pause
    goto :EOF

:REMOVE_CONTAINER
    echo [%TIMESTAMP%] Удаление контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        echo.
        echo Контейнер не существует
        pause
        goto :EOF
    )
    
    docker rm -f %CONTAINER_NAME% >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo [%TIMESTAMP%] Ошибка удаления контейнера >> "%LOG_FILE%"
        echo.
        echo [ОШИБКА] Не удалось удалить контейнер
        pause
        goto :EOF
    )
    
    echo.
    echo Контейнер успешно удален
    pause
    goto :EOF

:VIEW_LOGS
    docker inspect --format="{{.Name}}" %CONTAINER_NAME% >nul 2>&1 || (
        echo.
        echo Контейнер не существует
        pause
        goto :EOF
    )

    echo [%TIMESTAMP%] Просмотр логов контейнера %CONTAINER_NAME% >> "%LOG_FILE%"
    echo.
    echo Для выхода из просмотра логов нажмите CTRL+C
    echo.
    timeout /t 3 >nul

    :: Сохраняем логи во временный файл
    docker logs %CONTAINER_NAME% > temp_logs.txt

    :: Отображаем содержимое временного файла
    type temp_logs.txt

    :: Удаляем временный файл
    del temp_logs.txt

    pause
    goto :EOF