FROM php:apache
MAINTAINER "tigerwill90" <sylvain.muller90@gmail.com>


RUN set -x \
        && apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                git \
                make \
                wget

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-enable pdo_mysql

# Add Apache vhost, disable default and enable new vhost
ADD vhost.conf /etc/apache2/sites-available/
RUN a2dissite 000-default.conf
RUN a2ensite vhost.conf

# Enable Apache modules
RUN a2enmod rewrite

# Finally, restart Apache
RUN service apache2 restart

EXPOSE 80
