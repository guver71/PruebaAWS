# Usa la imagen base de PHP con Apache
FROM php:8.2-apache

# Mantenedor
LABEL maintainer="Santa"

# Habilita el módulo de reescritura de Apache
RUN a2enmod rewrite

# Instala dependencias necesarias para Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install zip pdo pdo_mysql

# Instala Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código de la aplicación
COPY . /var/www/html

# Configura permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/framework/views /var/www/html/storage/framework/cache /var/www/html/storage/framework/sessions \
    && chmod -R 775 /var/www/html/storage/framework

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala dependencias de Laravel usando Composer
RUN composer install

# Instala dependencias de Node.js y compila activos de Vite
RUN npm install && npm run build

# Variables de entorno
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Ajusta el archivo de configuración de Apache
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80
