#FROM debian:stable-slim
FROM nginx:1

# install general applications
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install apt-transport-https lsb-release ca-certificates wget nano htop
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt-get update

# install nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY www.conf /etc/nginx/conf.d/
RUN sed -i 's/^user.*/user  www-data;/' /etc/nginx/nginx.conf

# intsall php-fpm
RUN apt-get install -y php7.1 php7.1-cli php7.1-fpm libapache2-mod-php7.1 php7.1-common php7.1-gd php7.1-mysql php7.1-mcrypt php7.1-curl php7.1-intl php7.1-xsl php7.1-mbstring php7.1-zip php7.1-bcmath php7.1-iconv php7.1-soap php7.1-json php7.1-xml
COPY overrides.conf /etc/php/7.1/fpm/pool.d/z-overrides.conf
COPY php-fpm-startup /usr/bin/php-fpm
RUN chmod +x /usr/bin/php-fpm

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# complete the image
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
CMD ["/usr/bin/php-fpm"]

EXPOSE 443
