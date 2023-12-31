FROM php:8.1.0-apache
WORKDIR /var/www/html

# create a new linux user group called 'developer' with an arbitrary group id of '1000'
RUN groupadd -g 1000 developer

# create a new user called developer and add it to this group
RUN useradd -u 1000 -g developer developer



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

# # Copy the application code
COPY 'laravel-app' .

# #copy environment file
COPY 'laravel-app/.env.example' ./.env

# # composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer install 

# Generate optimized autoload files
RUN composer dump-autoload --optimize     

# change the owner and group of the current working directory to developer
COPY --chown=developer:developer . /var/www/html


ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APP_HOST=127.0.0.1  

COPY app.conf /etc/apache2/sites-available/000-default.conf

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


# changing 80 to port 8000 for our application inside the container, because as a regular user we cannot bind to system ports.
RUN sed -s -i -e "s/80/8000/" /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf



# PHP Extension
RUN docker-php-ext-install gettext intl pdo_mysql gd

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd 



RUN php artisan key:generate --ansi

RUN php artisan storage:link

USER developer

#  Client

FROM node:20-alpine as node

WORKDIR /var/www/html

COPY './laravel-app/package.json' .

RUN npm install

COPY . .

CMD npm run dev
