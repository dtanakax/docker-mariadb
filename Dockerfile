# Set the base image
FROM tanaka0323/debianjp:wheezy

# File Author / Maintainer
MAINTAINER Daisuke Tanaka, tanaka@infocorpus.com

ENV DEBIAN_FRONTEND noninteractive

# Environment variables
ENV ROOT_PASSWORD   password
ENV DB_NAME         demodb
ENV DB_USER         demo
ENV DB_PASSWORD     demopassword

# add our user and group first to make sure their IDs get assigned consistently, 
# regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db && echo 'deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/debian wheezy main' > /etc/apt/sources.list.d/mariadb.list

RUN apt-get update && apt-get install -yq procps mariadb-server hostname pwgen supervisor

# Adding the configuration file
COPY start.sh /start.sh
COPY my.cnf /my.cnf
COPY supervisord.conf /etc/
RUN chmod 755 /start.sh
RUN chmod 664 /my.cnf

RUN mkdir -p /var/log/mariadb/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/mariadb/general.log
RUN ln -sf /dev/stderr /var/log/mariadb/error.log

# Define mountable directories.
VOLUME ["/etc/mysql"]

# Set the port to 3306
EXPOSE 3306

# Set TERM environment variable.
ENV TERM dumb

# Executing sh
ENTRYPOINT ./start.sh