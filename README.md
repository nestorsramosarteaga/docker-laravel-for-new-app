# docker-laravel-nginx-mysql

This project uses Docker to set up a development environment for **Laravel**, **Nginx**, **MySQL**, and **PHP-FPM**.

---

## 🚀 Steps to Start the Environment

### 1. Copy the example environment file
```bash
cp .env.example .env
```

### 2. Update the following variables in the .env file:
- APP_NAME
- SRV_PORT_HOST
- DB_PORT_HOST
- DB_DATABASE
- DB_PASSWORD

### 3. Build the Docker containers
```bash
docker compose build
```

### 4. Start the Docker containers
```bash
docker compose up -d
```

### 5. Open a shell inside the PHP-FPM container
```bash
docker exec -it APP_NAME-php-fpm bash
```

> 📝 **Note:** Replace APP_NAME with the value you defined in your .env file.


### 6. Create a new Larvel App
```bash
laravel new .
```
