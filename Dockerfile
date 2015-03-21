# Set the base image
FROM debian:wheezy

# File Author / Maintainer
MAINTAINER Daisuke Tanaka, tanaka@infocorpus.com

ENV DEBIAN_FRONTEND noninteractive

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

# Create a directory for the source code.
RUN mkdir -p /var/log/mariadb && \
    mkdir -p /var/lib/mysql

# Define mountable directories.
VOLUME ["/etc/mysql/"]

# Set the port to 3306
EXPOSE 3306

# Set TERM environment variable.
ENV TERM dumb

# Executing sh
CMD ["/bin/bash", "/start.sh"]