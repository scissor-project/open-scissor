#!/bin/bash

set -euo pipefail
IFS=$'\\n\t'

# Set root and prelude password to random passwords
MARIADB_ROOT_PASS="$(pwgen 13 1)"
MARIADB_PRELUDE_PASS="$(pwgen 13 1)"
MARIADB_PRELUDE_USER="prelude"
MARIADB_PRELUDE_DBNAME="prelude"

# Setup prelude-manager config file
sed \
    -e "s/__MARIADB_PRELUDE_NAME__/${MARIADB_PRELUDE_DBNAME}/g" \
    -e "s/__MARIADB_PRELUDE_USER__/${MARIADB_PRELUDE_USER}/g" \
    -e "s/__MARIADB_PRELUDE_PASS__/${MARIADB_PRELUDE_PASS}/g" \
    -i /etc/prelude-manager/prelude-manager.conf

# Setup prelude-manager database and root password
mysql -u root << EOF
CREATE USER '${MARIADB_PRELUDE_USER}'@'%' IDENTIFIED BY '${MARIADB_PRELUDE_PASS}';
CREATE database ${MARIADB_PRELUDE_DBNAME};
GRANT ALL PRIVILEGES ON ${MARIADB_PRELUDE_DBNAME}.* TO '${MARIADB_PRELUDE_USER}'@'%';
UPDATE mysql.user SET Password=PASSWORD('${MARIADB_ROOT_PASS}') WHERE User='root';
FLUSH PRIVILEGES;
EOF
mysql -u "${MARIADB_PRELUDE_USER}" "${MARIADB_PRELUDE_DBNAME}" -p"${MARIADB_PRELUDE_PASS}" < /usr/share/libpreludedb/classic/mysql.sql

systemctl restart prelude-manager

PRELUDE_REGISTRATOR_PASS="password"

echo "${PRELUDE_REGISTRATOR_PASS}" > /etc/prelude/prelude-registrator.conf
systemctl restart prelude-registrator
