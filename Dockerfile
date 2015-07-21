FROM php:5.6-fpm

# import owncloud public key
RUN curl -o owncloud.asc -SL https://owncloud.org/owncloud.asc \
&&  gpg --import owncloud.asc \
&&  rm owncloud.asc

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
      bzip2 \
      sudo \
      libpng12-dev \
      libjpeg-dev \
      libmemcached-dev \
&&  rm -rf /var/lib/apt/lists/* \
&&  curl -L http://pecl.php.net/get/memcached-2.2.0.tgz >> /usr/src/php/ext/memcached.tgz \
&&  tar -xf /usr/src/php/ext/memcached.tgz -C /usr/src/php/ext/ \
&&  rm /usr/src/php/ext/memcached.tgz \
&&  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
&&  docker-php-ext-install \
      gd \
      zip \
      mysql \
      pdo_mysql \
      memcached-2.2.0

VOLUME /var/www/html

COPY docker-entrypoint.sh /entrypoint.sh

ENV OWNCLOUD_VERSION 8.1.0

# upstream tarballs include ./owncloud/ so this gives us /usr/src/owncloud
RUN curl -o owncloud.tar.bz2 -fSL https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 \
&&  curl -o owncloud.tar.bz2.asc -fSL https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc \
&&  gpg --verify owncloud.tar.bz2.asc \
&&  tar -xjf owncloud.tar.bz2 -C /usr/src/ \
&&  rm owncloud.tar.bz2* \
&&  chown -R www-data:www-data /usr/src/owncloud

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

