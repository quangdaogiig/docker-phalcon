FROM eboraas/apache-php
MAINTAINER quangdhd <quang.dao@giig.asia>

#RUN printf "xdebug.remote_enable=1\nxdebug.remote_host=10.254.254.254\nxdebug.remote_port=9001\nxdebug.remote_autostart=1\nxdebug.idekey=\"PHPSTORM\"" >> /etc/php5/mods-available/xdebug.ini

#RUN apt-get update && apt-get -y install apache2 php5.6 && apt-get clean && rm -rf /var/lib/apt/lists/*
# RUN /usr/sbin/a2dismod 'mpm_*' && /usr/sbin/a2enmod mpm_prefork

RUN /usr/sbin/a2enmod rewrite

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon 001-phalcon-ssl

WORKDIR /tmp
# Run build process on one line to avoid generating bloat via intermediate images
RUN /usr/bin/apt-get update && apt-get -y install git build-essential curl php-xdebug php-dev php-curl php-mysqlnd php-cli php-gd php-mcrypt php-intl libpcre3-dev gcc make && \
    /usr/bin/git clone --branch v3.0.1 --depth=1 git://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build/ && \
    ./install && \
    cd /tmp && \
    /bin/rm -rf /tmp/cphalcon/ && \
    /usr/bin/apt-get -y purge git php-dev libpcre3-dev build-essential gcc make && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /bin/echo 'extension=phalcon.so' >/etc/php/7.0/mods-available/phalcon.ini
RUN /usr/sbin/phpenmod phalcon
WORKDIR /var/www/phalcon/web
RUN /bin/echo '<html><body><h1>It works!</h1></body></html>' > /var/www/phalcon/web/index.html
WORKDIR /var/www/phalcon

#RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && ln -sf /proc/self/fd/1 /var/log/apache2/error.log

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
