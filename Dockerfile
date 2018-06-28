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
### Install some needed tools
###
RUN set -x \
        && apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                git \
                make \
                wget

ADD /vhost/vhost.conf /etc/apache2/sites-available

RUN set -x \
      # disable default vhost conf && enable new vhost
      && a2dissite 000-default.conf \
      && a2ensite vhost.conf \
      && a2enmod rewrite \
      \
      # clean-up
      && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps

###
### Install memcached
###
RUN set -x \
    && apt-get install --no-install-recommends --no-install-suggests -y \
      zlib1g-dev \
      libmemcached-dev \
    \
    && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && cd /usr/src/php/ext/memcached && git checkout -b php7 origin/php7 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached

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
### Init project and fix permission
###
RUN set -x \
  && mkdir -p /var/www/html/public \
  && chmod 0755 /var/www/html/public \
  && chown ${USER}:${GROUP} /var/www/html/public

VOLUME /var/www/html

EXPOSE 80

WORKDIR /var/www/html
