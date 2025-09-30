# =========================================================
# FASE 1: BUILD (Instala dependencias PHP, Node y Vite)
# =========================================================
FROM node:20-slim as build

# Instalar software de gestión de claves y repositorios
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    git \
    unzip \
    # Limpiar
    && rm -rf /var/lib/apt/lists/*

# Agregar el repositorio PPA de SURY (necesario para PHP 8.3 en Debian)
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list

# Actualizar e instalar PHP 8.3 y las extensiones necesarias
RUN apt-get update && apt-get install -y \
    php8.3-cli \
    php8.3-pgsql \
    php8.3-zip \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    # Limpiar al final
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente (copia desde la imagen oficial de Composer)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencia
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./
COPY vite.config.ts ./

# Instalar dependencias PHP, Node, y compilar React
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

# Copiar el resto del código de la aplicación
COPY . .

# =========================================================
# FASE 2: PRODUCCIÓN (Imagen Final - ligera y segura)
# =========================================================
# Usamos una imagen PHP FPM para producción (más ligera)
FROM php:8.3-fpm-alpine as production

# Instalar extensiones PHP necesarias (versión Alpine)
# Ajusta 'pdo_pgsql' o 'pdo_mysql' según tu base de datos.
RUN apk add --no-cache \
    nginx \
    supervisor \
    php83-pdo_pgsql \
    php83-zip \
    php83-mbstring \
    php83-xml \
    php83-curl \
    && rm -rf /var/cache/apk/*

# Copiar el código y los assets compilados de la etapa 'build'
WORKDIR /var/www/html
COPY --from=build /app /var/www/html

# Asegurar permisos y crear directorios de caché
RUN mkdir -p /var/www/html/storage/framework/cache \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Configurar Nginx y Supervisor
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer el puerto y CMD de inicio
EXPOSE 8080
# Render usa el puerto 8080 como default para Docker si no se especifica.

# El comando CMD ejecuta Supervisor, que inicia PHP-FPM y Nginx
CMD ["/usr/bin/supervisvisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# NOTA: Asegúrate de que tu .docker/nginx.conf escuche en el puerto 8080.
#       Asegúrate de que el Start Command en Render esté vacío o que apunte a este CMD.
