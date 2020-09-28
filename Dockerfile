FROM php:7.4-fpm-alpine

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install nano editor
RUN apk add nano

# Install dev dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    pcre-dev

# Install production dependencies
RUN apk add --no-cache \
    bash \
    curl \
    ffmpeg \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    imagemagick \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    make \
    mysql-client \
    nodejs \
    nodejs-npm \
    oniguruma-dev \
    yarn \
    openssh-client \
    rsync \
    zlib-dev

# Install PECL and PEAR extensions
RUN pecl install \
    imagick \
    redis

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
    imagick \
    redis

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure opcache --enable-opcache

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    calendar \
    curl \
    exif \
    gd \
    iconv \
    intl \
    mbstring \
    opcache \
    pdo \
    pdo_mysql \
    pcntl \
    sockets \
    tokenizer \
    xml \
    zip

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_MEMORY_LIMIT -1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install composer plugin that downloads packages in parallel to speed up the installation process
RUN composer global require hirak/prestissimo

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*"

# Install PHP Coding Standards Fixer
RUN composer global require friendsofphp/php-cs-fixer

# Cleanup dev dependencies
RUN apk del -f .build-deps

# Setup working directory
WORKDIR /var/www
