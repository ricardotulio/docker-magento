FROM ubuntu:12.04

MAINTAINER Ricardo Ledo <ledo.tulio@gmail.com>
MAINTAINER Davi Marcondes Moreira <davi.marcondes.moreira@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_PID_FILE  /var/run/apache2.pid

ENV MYSQL_HOST               mysql
ENV MYSQL_USER               magento
ENV MYSQL_PASSWORD           magento
ENV MAGENTO_LOCALE           pt_BR
ENV MAGENTO_TIMEZONE         America/Sao_Paulo
ENV MAGENTO_DEFAULT_CURRENCY BRL
ENV MAGENTO_URL              http://127.0.0.1
ENV MAGENTO_ADMIN_FIRSTNAME  Admin
ENV MAGENTO_ADMIN_LASTNAME   MyStore
ENV MAGENTO_ADMIN_EMAIL      admin@example.com
ENV MAGENTO_ADMIN_USERNAME   admin
ENV MAGENTO_ADMIN_PASSWORD   abc1234

RUN apt-get update && \
    apt-get install -y \
        apache2 \
        php-pear \
        php5 \
        php5-cli \
        php5-common \
        php5-curl \
        php5-dev \
        php5-gd \
        php5-mcrypt \
        php5-mysql \
        php5-pgsql \
        php5-xdebug \
        zip \
        unzip

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ["a2enmod", "php5"]
RUN ["a2enmod", "rewrite"]

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

ADD ./1.8.1.0/etc/apache2/sites-available/default /etc/apache2/sites-available/default

RUN mkdir /docker-magento/ /docker-magento-modules/

ADD ./1.8.1.0/magento-1.8.1.0.tar.gz /docker-magento/

RUN rm /var/www/index.html

WORKDIR /docker-magento
RUN cp -av magento/* /var/www && \
    chown -R www-data.www-data /var/www && \
    rm -rf magento magento-1.8.1.0.tar.gz

ADD ./1.8.1.0/usr/local/bin/ /usr/local/bin/

RUN composer global require phpunit/phpunit
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
