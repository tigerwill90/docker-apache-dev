FROM php:apache
MAINTAINER "tigerwill90" <sylvain.muller90@gmail.com>


ENV USER=daemon
ENV GROUP=daemon

VOLUME /var/www/html/public

###
### Install some needed tools
###
RUN set -x \
        && apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                git \
                make \
                wget \
      \
      # wget custom vhost file
      && cd /etc/apache2/sites-available \
      && wget https://raw.githubusercontent.com/tigerwill90/docker-apache-dev/0.x/vhost/vhost.conf \
      \
      # disable default vhost conf && enable new vhost
      && a2dissite 000-default.conf \
      && a2ensite vhost.conf \
      && a2enmod rewrite \
      \
      # clean-up
      && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps \
      \
      # restart apache
      && service apache2 restart

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
### Fix permission
###
RUN set -x \
  && chmod 0755 /var/www/html \
  && chown ${USER}:${GROUP} /var/www/html

EXPOSE 80

WORKDIR /var/www/html
