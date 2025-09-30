# =========================================================
# FASE 1: BUILD (Instala dependencias PHP, Node y Vite)
# =========================================================
FROM node:20-slim as build

# Instalar PHP y Composer en el entorno de build de Node
# Esto nos permite ejecutar Composer y Node/Vite en la misma etapa.
RUN apt-get update && apt-get install -y \
    php8.3-cli \
    php8.3-pgsql \
    php8.3-zip \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente
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
