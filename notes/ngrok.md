🔹 Зарегистрируйтесь на `ngrok.com` (есть бесплатный тариф).

🔹 **Добавьте токен аутентификации в ngrok.yml или при запуске:**

```bash
ngrok authtoken ВАШ_ТОКЕН
ngrok http 5678
```

```bash
ngrok config check
```

**Если всё работает, вы увидите:**

```bash
Forwarding  https://ваш-субдомен.ngrok.io -> http://localhost:5678
```
