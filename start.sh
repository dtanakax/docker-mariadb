#!/bin/bash
set -e

ROOT_PASSWORD=${ROOT_PASSWORD:-$(pwgen -s -1 16)}
DB_NAME=${DB_NAME:-demodb}
DB_USER=${DB_USER:-demo}
DB_PASSWORD=${DB_PASSWORD:-$(pwgen -s -1 16)}

echo "=> Installing MariaDB ..."
mysql_install_db
chown -R mysql:mysql /var/lib/mysql
/usr/bin/mysqld_safe > /dev/null 2>&1 &
mysqladmin --silent --wait=36 ping || exit 1
echo "=> Done"

echo "=> Creating database ..."

# Create the superuser.
mysql -u root <<-EOF
use mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$ROOT_PASSWORD") WHERE user='root';
EOF

if [[ $DB_NAME != "" ]]; then
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;"

    if [[ $DB_USER != "" ]]; then
        mysql -u root -e "GRANT ALL ON \`$DB_NAME\`.* to '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
    fi
fi

echo "========================================================================"
echo "You can now connect to this MariaDB Server using:"
echo ""
echo "    mysql -u root -p$ROOT_PASSWORD"
echo "    mysql -u$DB_USER -p$DB_PASSWORD -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"

mysqladmin -uroot shutdown
echo "=> Done"

# Executing supervisord
supervisord -n