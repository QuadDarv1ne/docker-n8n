# 🚀 n8n в Docker с автоматическим запуском

![n8n Logo](https://n8n.io/n8n-logo.png)

![n8n](img/n8n.png)

**Репозиторий для быстрого развёртывания [n8n](https://n8n.io) в Docker с поддержкой Windows/Linux**

[Doker (n8n) - Secure Workflow Automation for Technical Teams](https://hub.docker.com/r/n8nio/n8n)

## 📦 Быстрый старт

### 🔍 Для Windows

1. Скачайте [run_n8n.bat](run_n8n.bat)
2. Запустите от имени администратора:

   ```bash
   run_n8n.bat
   ```

### 🔍 Для Linux/macOS

```bash
docker run -d \
  -p 5678:5678 \
  -e N8N_HOST=0.0.0.0 \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n
```

## 🔧 Настройки

| Переменная                     | Описание                          | Значение по умолчанию |
|--------------------------------|-----------------------------------|-----------------------|
| `N8N_DIAGNOSTICS_ENABLED`      | Отключение аналитики              | `false`               |
| `N8N_RUNNERS_ENABLED`          | Включение фоновых задач           | `true`                |
| `N8N_BASIC_AUTH_USER`          | Логин для входа (рекомендуется)  | -                     |

## 📂 Структура проекта

```textline
docker-n8n/
│
├── archive/                     # Архивные файлы и резервные копии
├── img/                         # Изображения, используемые в проекте
├── notes/                       # Различные заметки и документация
├── preview_versions/            # Предыдущие версии проекта
├── templates/                   # Шаблоны для различных конфигураций
│
├── .env                         # Файл с переменными окружения
├── .env-sample                  # Пример файла с переменными окружения
├── .gitignore                   # Файлы и директории, игнорируемые Git
├── generate_encryption_key.bat  # Скрипт для генерации ключа шифрования
├── LICENSE                      # Лицензионное соглашение
├── run_n8n.bat                  # Скрипт для запуска n8n на Windows
├── docker-compose.yml           # Конфигурация Docker Compose для развертывания
└── README.md                    # Основная документация проекта
```

## 🌟 Возможности

- Автоматическое сохранение данных в Docker Volume
- Поддержка UTF-8 и русского языка
- Готовые примеры workflows в папке `templates/`

## 🤝 Как помочь проекту

1. Форкните репозиторий
2. Добавьте улучшения через Pull Request

## 📜 Лицензия

[The Emotional License (EL)](LICENSE)

---

💼 **Автор:** Дуплей Максим Игоревич

📲 **Telegram:** @quadd4rv1n7

📅 **Дата:** 25.05.2025

▶️ **Версия 1.0**

```textline
※ Предложения по сотрудничеству можете присылать на почту ※
📧 maksimqwe42@mail.ru
```
