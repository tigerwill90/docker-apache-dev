###
###             DOCKER LAMP STACK
###             Start new project with full stack in few minutes
###
###

FROM php:apache
MAINTAINER "tigerwill90" <sylvain.muller90@gmail.com>

ENV USER=daemon
ENV GROUP=daemon

###
### Install tools
###
RUN set -x \
        && apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                git \
                make \
                wget

###
### Install memcached
###
RUN set -x \
        && buildDeps=" \
                libmemcached-dev \
                zlib1g-dev \
        " \
        && doNotUninstall=" \
                libmemcached11 \
                libmemcachedutil2 \
        " \
        && apt-get install -y $buildDeps --no-install-recommends \
        && rm -r /var/lib/apt/lists/* \
        \
        && docker-php-source extract \
        && git clone --branch php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached/ \
        && docker-php-ext-install memcached \
        \
        && docker-php-source delete \
        && apt-mark manual $doNotUninstall \
        \
        #clean-up
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

###
### Install PDO
###
RUN set -x \
   && docker-php-ext-install pdo_mysql \
   && docker-php-ext-enable pdo_mysql

###
### Install composer
###
RUN set -x \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer self-update

###
### Adding custom vhost conf
###
ADD /vhost/vhost.conf /etc/apache2/sites-available

###
### Override default vhost conf
###
RUN set -x \
      # disable default vhost conf && enable custom vhost
      && a2dissite 000-default.conf \
      && a2ensite vhost.conf \
      && a2enmod rewrite

###
### Init project and fix permission
###
RUN set -x \
  && mkdir -p /var/www/html/public \
  && chmod 0755 /var/www/html/public \
  && chown ${USER}:${GROUP} /var/www/html/public

VOLUME /var/www/html

EXPOSE 80

WORKDIR /var/www/html
