#!/bin/sh

echo "Wait for prelude-manager-db to start"
while ! nc -vvz prelude-manager-db 3306; do echo "Wating 10 secs..."; sleep 10; done

mysql -u root --password="root" -h"prelude-manager-db" -P"3306" << EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE USER IF NOT EXISTS 'prelude'@'%' IDENTIFIED BY 'prelude';
CREATE DATABASE IF NOT EXISTS prelude;
GRANT ALL PRIVILEGES ON prelude.* TO 'prelude'@'%';
UPDATE mysql.user SET Password=PASSWORD('prelude') WHERE User='prelude';
FLUSH PRIVILEGES;
EOF

mysql -u "prelude" --password="prelude" --database="prelude" -h"prelude-manager-db" -P"3306" < /usr/share/libpreludedb/classic/mysql.sql

# Create prelude-manager profile
prelude-admin add "prelude-manager" --uid 0 --gid 0

/usr/sbin/prelude-manager > "$SCISSOR_LOG_DIR"/prelude-manager-output.log 2>&1 &
/usr/bin/prelude-admin registration-server prelude-manager --no-confirm --keepalive --passwd-file /etc/prelude/prelude-registrator.conf > "$SCISSOR_LOG_DIR"/prelude-registrator-output.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/prelude-debug.log \
  "$SCISSOR_LOG_DIR"/prelude-manager-output.log \
  "$SCISSOR_LOG_DIR"/prelude-registrator-output.log
