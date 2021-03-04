FROM php:7.4-fpm-alpine

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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
	libwebp-dev \
    libzip-dev \
    make \
    mysql-client \
    nano \
    nodejs \
    nodejs-npm \
    oniguruma-dev \
    openssh-client \
    rsync \
    util-linux \
    yarn \
    zlib-dev \
    zsh

# Install PECL and PEAR extensions
RUN pecl install \
    imagick \
    redis

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
    imagick \
    redis

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
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

# Install git flow
RUN sh -c "$(wget https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh -O -)" && rm -rf gitflow

# Install oh-my-zsh
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Customize oh-my-zsh theme
RUN sed -i '1,2 s/^/#/' ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
RUN sed -i '3 i PROMPT="%(?:%{\$fg_bold[green]%}➜ %n:%{\$fg_bold[red]%}➜ )"' ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
RUN sed -i "4 i PROMPT+=' %{\$fg[cyan]%}%~%{\$reset_color%} \$(git_prompt_info)'" ~/.oh-my-zsh/themes/robbyrussell.zsh-theme

# Customize oh-my-zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting laravel npm git-flow-avh)/g' ~/.zshrc

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_MEMORY_LIMIT -1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*"

# Install PHP Coding Standards Fixer
RUN composer global require friendsofphp/php-cs-fixer

# Install Laravel Envoy
RUN composer global require laravel/envoy

# Cleanup dev dependencies
RUN apk del -f .build-deps

# Setup working directory
WORKDIR /var/www
