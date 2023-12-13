FROM php:8.1.0-apache
# Set the working directory
WORKDIR /var/www/html

# RUN usermod -u 1000 www-data

# Mod Rewrite
RUN a2enmod rewrite


# Linux Library
RUN apt-get update -y && apt-get install -y \
    libicu-dev \
    libmariadb-dev \
    unzip zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev 

# PHP Extension
RUN docker-php-ext-install gettext intl pdo_mysql gd

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd 


ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy the application code
COPY 'laravel-app' .


# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install 

# Installing dependencies from lock file (including require-dev)
# RUN composer update

# Generate optimized autoload files
RUN composer dump-autoload --optimize

#copy environment file
COPY 'laravel-app/.env.example' ./.env

RUN php artisan key:generate --ansi

RUN php artisan storage:link

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache


EXPOSE 8000

# Start the Apache server
# CMD ["apache2-foreground"]


