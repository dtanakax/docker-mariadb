# Set the base image
FROM tanaka0323/centosjp:latest

# File Author / Maintainer
MAINTAINER tanaka@infocorpus.com

# add our user and group first to make sure their IDs get assigned consistently, 
# regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Yum update
RUN yum -y update

# Add EPEL Repository
RUN yum install -y epel-release

# Installing tools
RUN yum install -y mariadb-server hostname pwgen supervisor

# Yum clean up
RUN yum clean all

# Adding the configuration file
ADD start.sh /start.sh
ADD my.cnf /etc/my.cnf
ADD supervisord.conf /etc/
RUN chmod 755 /start.sh
RUN chmod 664 /etc/my.cnf

# Create a directory for the source code.
RUN mkdir -p /var/log/mariadb && \
    mkdir -p /var/lib/mysql

# Define mountable directories.
VOLUME ["/var/lib/mysql", "/var/log/mariadb"]

# Set the port to 3306
EXPOSE 3306

# Set TERM environment variable.
ENV TERM dumb

# Executing sh
CMD ["/bin/bash", "/start.sh"]
