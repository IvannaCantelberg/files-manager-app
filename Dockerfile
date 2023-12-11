FROM php:8.1.0-apache

# RUN usermod -u 1000 www-data

# Mod Rewrite
RUN a2enmod rewrite

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/html/

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


# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-scripts --no-autoloader --no-dev


# Copy the application code
COPY . /var/www/html

# Set the working directory
WORKDIR /var/www/html


# Generate optimized autoload files
RUN composer dump-autoload --optimize


# Build the assets using Laravel Mix
RUN npm install && npm run dev


# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

# Start the Apache server
CMD ["apache2-foreground"]

