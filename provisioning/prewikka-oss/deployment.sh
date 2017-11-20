#!/bin/bash

set -xeuo pipefail
IFS=$'\\n\t'

prewikka_host="$1"
hostname="$2"
preludedb_host="$3"

preludedb_user="prelude"
preludedb_passwd="preludepasswd"
preludedb_name="prelude"

prewikka_user="prewikka"
prewikka_passwd="$(pwgen 13 1)"
prewikka_name="prewikka"

mariadb_root_passwd="$(pwgen 13 1)"

sed \
    -e "s/__PRELUDEDB_HOST__/${preludedb_host}/g" \
    -e "s/__PRELUDEBD_USER__/${preludedb_user}/g" \
    -e "s/__PRELUDEDB_PASSWD__/${preludedb_passwd}/g" \
    -e "s/__PRELUDEDB_NAME__/${preludedb_name}/g" \
    -e "s/__PREWIKKA_HOST__/${prewikka_host}/g" \
    -e "s/__PREWIKKA_USER__/${prewikka_user}/g" \
    -e "s/__PREWIKKA_PASSWD__/${prewikka_passwd}/g" \
    -e "s/__PREWIKKA_NAME__/${prewikka_name}/g" \
    -i /etc/prewikka/prewikka.conf

# Setup prewikka database and root password
mysql -u root << EOF
CREATE USER '${prewikka_user}'@'%' IDENTIFIED BY '${prewikka_passwd}';
CREATE database ${prewikka_name};
GRANT ALL PRIVILEGES ON ${prewikka_name}.* TO '${prewikka_user}'@'%';
UPDATE mysql.user SET Password=PASSWORD('${mariadb_root_passwd}') WHERE User='root';
FLUSH PRIVILEGES;
EOF

# provide a link to the main page through slipstream

#link=http://${hostname}/
#ss-set ss:url.service ${link}

echo "Prewikka ready on ${hostname}!"

systemctl restart httpd
