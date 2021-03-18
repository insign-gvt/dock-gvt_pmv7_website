FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

WORKDIR /app

RUN apt-get update -q \
    && apt-get install --no-install-recommends -qy \
        supervisor \
        gosu \
        nginx \
        tzdata \
        wget \
        php7.4 \
        php7.4-fpm \
        php7.4-dom \
        php7.4-zip \
        php7.4-pdo \
        php7.4-mysql \
        php7.4-mbstring \
        php7.4-gd \
        curl \
        ca-certificates \
        unzip

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet \
    && rm composer-setup.php

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs

# Yarn
RUN npm install -g yarn

# Security Checker
RUN wget https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64
RUN mv local-php-security-checker_1.0.0_linux_amd64 /usr/bin/local-php-security-checker
RUN chmod +x /usr/bin/local-php-security-checker

# Clean-up useless files
RUN apt-get autoremove -qy --purge apt-transport-https\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Dialout GID is 20 and it's the default UID/GID on MacOS
    && groupmod -g 80 dialout

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf
COPY php.ini /etc/php/7.4/cli/conf.d/50-setting.ini
COPY php.ini /etc/php/7.4/fpm/conf.d/50-setting.ini
COPY pool.conf /etc/php/7.4/fpm/pool.d/www.conf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
