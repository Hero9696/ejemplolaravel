# =========================================================
# FASE 1: BUILD (Instala dependencias PHP, Node y Vite)
# =========================================================
# Usamos una imagen Node basada en Debian para instalar y compilar todo.
FROM node:20-slim as build

# Instalar software base, claves GPG, y gestores de paquetes
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    curl \
    git \
    unzip \
    # Limpiar
    && rm -rf /var/lib/apt/lists/*

# Agregar el repositorio PPA de SURY (necesario para PHP 8.3 en Debian)
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list

# Instalar PHP 8.3 y las extensiones necesarias
RUN apt-get update && apt-get install -y \
    php8.3-cli \
    php8.3-pgsql \
    php8.3-zip \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    gettext \
    # Limpiar al final
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencia y código (todo a la vez para que 'artisan' esté disponible)
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./
COPY vite.config.ts ./
COPY . .

# Instalar dependencias PHP (Composer ya puede encontrar 'artisan')
RUN composer install --no-dev --optimize-autoloader

# Instalar dependencias Node y compilar React
RUN npm install
RUN npm run build

# =========================================================
# FASE 2: PRODUCCIÓN (Imagen Final)
# =========================================================
# Usamos 'php:8.3-fpm' para una base consistente de Debian/PHP
FROM php:8.3-fpm as production

# Instalar Nginx, Supervisor y Bash (necesario para el script de Supervisor)
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    bash \
    # Limpiar
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar el código y los assets compilados de la etapa 'build'
WORKDIR /var/www/html
COPY --from=build /app /var/www/html

# Asegurar permisos de escritura en las carpetas de Laravel
RUN mkdir -p /var/www/html/storage/framework/cache \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Copiar archivos de configuración
COPY .docker/nginx.conf.template /etc/nginx/conf.d/default.conf
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer el puerto
EXPOSE 8080

# Comando de inicio: Ejecutar Supervisor, que iniciará PHP-FPM y Nginx
# Supervisor está en /usr/bin/supervisord en Debian
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
