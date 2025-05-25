# Установка Cloudflared

1. Windows (PowerShell):

```bash
# Скачать и распаковать cloudflared
Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile "cloudflared.exe"
./cloudflared.exe --version
```

Linux/macOS (Terminal):

```bash
# Linux (Debian/Ubuntu)
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

# macOS (Intel)
brew install cloudflared
# или вручную:
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz | tar -xz
sudo mv cloudflared /usr/local/bin/
```

2. Аутентификация в Cloudflare

2.1) Войдите в аккаунт Cloudflare (если нет — зарегистрируйтесь).
2.2) Выполните аутентификацию:

```bash
cloudflared tunnel login
```

2.3) Откроется браузер → выберите домен, к которому привязать туннель.
2.4) После успешной аутентификации в папке ~/.cloudflared/ появится сертификат.

3. Создание туннеля

```bash
# Создаем туннель (название — любое, например "n8n-tunnel")
cloudflared tunnel create n8n-tunnel
```

В выводе будет Tunnel ID (сохраните его).

4. Настройка маршрута (DNS)

4.1. Создайте DNS-запись для туннеля:

```bash
cloudflared tunnel route dns n8n-tunnel n8n.yourdomain.com
```

- ваш-субдомен.example.com — замените на реальный поддомен (например, n8n.yourdomain.com).

4.2. Проверьте DNS в панели Cloudflare:

- В разделе DNS → Records должна появиться запись типа CNAME с указанием на ваш-субдомен.cfargotunnel.com.

5. Конфигурационный файл

Создайте файл ~/.cloudflared/config.yml (или отредактируйте существующий):

```yaml
tunnel: ваш-tunnel-id
credentials-file: /home/ваш-пользователь/.cloudflared/ваш-tunnel-id.json

ingress:
  - hostname: n8n.yourdomain.com  # Ваш поддомен
    service: http://localhost:5678  # Порт n8n
  - service: http_status:404  # Для всех остальных запросов
```

- ваш-tunnel-id — ID из шага 3.
- ваш-субдомен.example.com — ваш поддомен.

6. Запуск туннеля

```bash
# Запуск в текущей сессии (для теста)
cloudflared tunnel run n8n-tunnel

# Запуск в фоне (демон)
cloudflared tunnel --config ~/.cloudflared/config.yml run n8n-tunnel
```

**После запуска туннель будет доступен по адресу:** https://ваш-субдомен.example.com

7. Настройка Telegram Webhook в n8n

7.1. В ноде Telegram Trigger укажите:
```
Webhook URL: https://ваш-субдомен.example.com/webhook
```

7.2. Сохраните и активируйте workflow.
