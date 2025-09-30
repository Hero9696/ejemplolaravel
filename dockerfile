# 1. Fase de Build: Instalar dependencias y compilar assets
# Usamos una imagen que ya incluye PHP y Composer
FROM php:8.3-fpm as base

# Instalar dependencias del sistema operativo (para PHP y Node)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libzip-dev \
    # Herramientas necesarias para la compilación de Vite/Node
    nodejs \
    npm \
    # Limpiar
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP (ej: zip, pdo_pgsql/pdo_mysql)
# Ajusta estas extensiones según tu base de datos (PostgreSQL o MySQL)
RUN docker-php-ext-install pdo pdo_pgsql zip

# Instalar Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de configuración y código para la fase de build
# Solo copiamos los archivos necesarios para composer y npm
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./
COPY vite.config.js ./

# Instalar dependencias de PHP y Node (Build Command)
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

# Copiar el código fuente completo del proyecto
COPY . .

# Generar la clave de la aplicación y limpiar permisos (seguro para Docker)
RUN php artisan key:generate

# ----------------------------------------------------------------------------------

# 2. Fase de Producción: Imagen final ligera
# Usamos una imagen FPM más pequeña para producción
FROM base as production

# Limpiar las dependencias de desarrollo y los archivos temporales
RUN composer dump-autoload --no-dev --optimize

# Quitar las carpetas que no son necesarias en la imagen final para reducir tamaño
RUN rm -rf node_modules resources storage/framework/cache
RUN rm -rf composer.json composer.lock package.json package-lock.json vite.config.js

# Asegúrate de que los permisos sean correctos
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Puerto por defecto de PHP-FPM
EXPOSE 9000

# El comando de inicio será gestionado por un servidor web (Nginx) y Render.
# Necesitarás configurar un servidor web que se comunique con este contenedor FPM.
# Dado que Render espera un comando de inicio simple para un Web Service:
CMD ["php-fpm"]
