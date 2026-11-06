FROM php:8.4-fpm-alpine


ARG USER_UID=1000
ARG USER_GID=1000

# Install system dependencies required for building PHP extensions
RUN apk add --no-cache \
    bash \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev

# Configure GD extension with proper image library support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

# Install WordPress required and recommended PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    intl \
    mysqli \
    opcache \
    pdo_mysql \
    soap \
    zip

RUN apk add --no-cache shadow

RUN groupmod -g 1000 www-data && \
    usermod -u 1000  -g 1000 www-data

RUN apk add --no-cache mariadb-client
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
                                                        chmod +x wp-cli.phar && \
                                                        mv wp-cli.phar /usr/local/bin/wp


RUN  apk add --update linux-headers                                                        
RUN apk add  --no-cache $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

  


