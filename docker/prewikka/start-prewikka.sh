#!/bin/sh

# Wait for mariadb to start
echo "Wait for mariadb to start"
while ! nc prelude-manager-db 3306 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

mysql -u root --password="root" -h"prelude-manager-db" -P"3306" << EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE USER IF NOT EXISTS 'prewikka'@'%' IDENTIFIED BY 'prewikka';
CREATE DATABASE IF NOT EXISTS prewikka;
GRANT ALL PRIVILEGES ON prewikka.* TO 'prewikka'@'%';
UPDATE mysql.user SET Password=PASSWORD('prewikka') WHERE User='prewikka';
FLUSH PRIVILEGES;
EOF

httpd > "$SCISSOR_LOG_DIR"/httpd-output.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/prewikka.log \
  "$SCISSOR_LOG_DIR"/httpd-output.log \
  /var/log/httpd/access_log \
  /var/log/httpd/error_log \
  /var/log/httpd/prelude.error \
  /var/log/httpd/prelude.log
