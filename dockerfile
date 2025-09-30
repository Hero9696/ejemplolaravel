# 1. Usar una imagen base que incluya PHP y Nginx/Supervisor
FROM tiangolo/node-docker:22-bookworm as base
# Nota: tiangolo/node-docker es excelente porque tiene Node y un buen manejo de procesos.

# Instalar PHP y dependencias (Ajusta la versión de PHP si es necesario)
RUN apt-get update && apt-get install -y \
    php8.3-fpm \
    php8.3-pgsql \
    php8.3-cli \
    php8.3-zip \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    composer \
    nginx \
    supervisor \
    unzip \
    git \
    # Limpiar
    && rm -rf /var/lib/apt/lists/*

# Configurar el directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración para Composer y NPM
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./
COPY vite.config.js ./

# Instalar dependencias y compilar assets
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

# Copiar el código fuente completo del proyecto
COPY . .

# Configurar Nginx para que apunte a la carpeta /public
COPY .docker/nginx.conf /etc/nginx/sites-enabled/default

# Configurar Supervisor para que ejecute PHP-FPM y Nginx
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------------------------------------------------------------------------------

# Configuración de Producción Final (Misma imagen, solo limpieza de dependencias)
FROM base as production

# Limpiar dependencias de desarrollo
RUN composer dump-autoload --no-dev --optimize

# Asegurar permisos
RUN chown -R www-data:www-data /app/storage \
    && chown -R www-data:www-data /app/bootstrap/cache

# Exponer el puerto
EXPOSE 80

# Comando de inicio: Ejecutar supervisor, que lanzará Nginx y PHP-FPM
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
