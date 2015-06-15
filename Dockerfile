# Set the base image
FROM dtanakax/debianjp:wheezy

# File Author / Maintainer
MAINTAINER Daisuke Tanaka, dtanakax@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# add our user and group first to make sure their IDs get assigned consistently, 
# regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 199369E5404BD5FC7D2FE43BCBCB082A1BB943DB

ENV MARIADB_MAJOR 5.5
ENV MARIADB_VERSION 5.5.44+maria-1~wheezy

RUN echo "deb http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/$MARIADB_MAJOR/debian wheezy main" > /etc/apt/sources.list.d/mariadb.list

RUN apt-get update && \
    apt-get -y install mariadb-server=$MARIADB_VERSION libmysqlclient18=$MARIADB_VERSION mysql-common=$MARIADB_VERSION pwgen && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Adding the configuration file
COPY start.sh /start.sh
COPY my.cnf /my.cnf
RUN chmod 755 /start.sh
RUN chmod 664 /my.cnf

RUN mkdir -p /var/log/mariadb/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/mariadb/general.log
RUN ln -sf /dev/stderr /var/log/mariadb/error.log

# Environment variables
ENV ROOT_PASSWORD   password
ENV DB_NAME         demodb
ENV DB_USER         demo
ENV DB_PASSWORD     demopassword

# Define mountable directories.
VOLUME ["/var/lib/mysql", "/etc/mysql"]

ENTRYPOINT ["./start.sh"]

# Set the port to 3306
EXPOSE 3306

# Set TERM environment variable.
ENV TERM dumb

CMD ["/usr/bin/mysqld_safe"]