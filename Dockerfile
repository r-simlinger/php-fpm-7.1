FROM debian:stable-slim
RUN apt-get update
RUN apt-get -y install apt-transport-https lsb-release ca-certificates wget nano htop
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt-get update
RUN apt-get install -y php7.1 php7.1-cli php7.1-fpm libapache2-mod-php7.1 php7.1-common php7.1-gd php7.1-mysql php7.1-mcrypt php7.1-curl php7.1-intl php7.1-xsl php7.1-mbstring php7.1-zip php7.1-bcmath php7.1-iconv php7.1-soap php7.1-json php7.1-xml
COPY overrides.conf /etc/php/7.1/fpm/pool.d/z-overrides.conf
COPY php-fpm-startup /usr/bin/php-fpm

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

RUN chmod +x /usr/bin/php-fpm
CMD ["/usr/bin/php-fpm"]

EXPOSE 9000

