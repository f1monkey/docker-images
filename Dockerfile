FROM php:7.4-cli-alpine

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV COMMON_PACKAGES="git bash bash-completion nano vim curl coreutils fcgi unzip tzdata net-tools openssh-client openssh-keygen openssh-keysign openrc sudo entr"
RUN apk add --no-cache ${COMMON_PACKAGES}

ENV PHP_INI_TIMEZONE=UTC
RUN ln -fs /usr/share/zoneinfo/${PHP_INI_TIMEZONE} /etc/localtime

ENV PHP_RUNDEPS="util-linux-dev pcre-dev zlib-dev libzip-dev libgd libpng-dev libpq icu-libs libmcrypt autoconf libevent"
RUN apk add --no-cache ${PHP_RUNDEPS}

ENV PHP_EXTENSIONS="dom iconv posix soap intl bcmath sockets zip gd curl mbstring pcntl pgsql pdo pdo_pgsql json simplexml session xml ctype" \
    PHP_BUILDDEPS="openssl-dev icu-dev libmcrypt-dev pcre-dev libzip-dev curl-dev libxml2-dev postgresql-dev gcc g++ libtool make binutils cyrus-sasl-dev oniguruma-dev" \
    PECL_EXTENSIONS="apcu timezonedb uuid redis"

RUN apk add --no-cache --virtual .php_builddeps ${PHP_BUILDDEPS} ${PHPIZE_DEPS} \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install ${PHP_EXTENSIONS} \
    && docker-php-ext-enable ${PHP_EXTENSIONS} \
    && for EXT in ${PECL_EXTENSIONS}; do \
        pecl install ${EXT} \
        && EXT=$(echo ${EXT} | cut -f1 -d-) \
        && docker-php-ext-enable ${EXT} && \
        ( php -m | grep "^${EXT}$" ); \
    done \
    && apk del .php_builddeps

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_HOME=/opt/composer
COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer

ARG USER_GID=1000
ARG USER_UID=1000
RUN addgroup -g ${USER_GID} app \
  && adduser -D -s /bin/bash -G app -u ${USER_UID} app \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && composer global require bamarni/symfony-console-autocomplete \
  && symfony-autocomplete composer | tee /usr/share/bash-completion/completions/composer \
  && chown -R app:app /opt

COPY php.ini     /usr/local/etc/php/php.ini
COPY conf.d                    /usr/local/etc/php/conf.d

RUN composer global require hirak/prestissimo

COPY start.sh /scripts/start.sh
COPY wait-for-it.sh /scripts/wait-for-it.sh
COPY server.sh /scripts/server.sh

RUN chmod +x /scripts/start.sh \
    && chmod +x /scripts/server.sh \
    && chmod +x /scripts/wait-for-it.sh

WORKDIR /srv
RUN chown -R app:app /srv
USER app

ENTRYPOINT /scripts/start.sh