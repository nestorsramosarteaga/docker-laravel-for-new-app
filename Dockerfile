FROM php:8.4-fpm

# Variables ARG para UID y GID
ARG PUID=1000
ARG PGID=1000

# Instalar utilidades y dependencias del sistema
RUN apt-get update && apt-get install -y \
  git \
  curl \
  zip \
  unzip \
  nano \
  bash \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libonig-dev \
  libxml2-dev \
  libzip-dev \
  libcurl4-openssl-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) pdo pdo_mysql gd zip \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && apt-get clean

# Copiar php.ini de desarrollo como base
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Crear usuario sin privilegios
RUN groupadd -g ${PGID} appuser \
  && useradd -u ${PUID} -g appuser -s /bin/bash -m appuser

# Crear carpetas necesarias para Laravel y asignar permisos (AÚN como root)
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
  && chown -R appuser:appuser /var/www/html \
  && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Cambiar a appuser
USER appuser

# Definir PATH y COMPOSER_HOME
ENV COMPOSER_HOME="/home/appuser/.composer"
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"

# Instalar Laravel Installer como appuser
RUN composer global require laravel/installer

# Instalar NVM, la última versión estable de Node.js y npm
ENV NVM_DIR="/home/appuser/.nvm"
ENV PATH="$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node || echo 'stable')/bin:$PATH"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
  . "$NVM_DIR/nvm.sh" && \
  nvm install stable && \
  nvm use stable && \
  nvm alias default stable && \
  npm install -g npm && \
  echo 'export NVM_DIR="$HOME/.nvm"' >> /home/appuser/.bashrc && \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/appuser/.bashrc && \
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/appuser/.bashrc

# Directorio de trabajo
WORKDIR /var/www/html