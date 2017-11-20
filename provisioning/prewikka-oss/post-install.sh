#!/bin/bash

set -xeuo pipefail
IFS=$'\\n\t'

# Setup mariadb
systemctl enable mariadb
systemctl start mariadb

# similar to mysql_secure_installation
mysql -u root << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

setsebool -P httpd_can_network_connect=1

cat << EOF > /etc/httpd/conf.d/prewikka.conf
<VirtualHost *:80>
		# This is optional: handling is faster if this is done by Apache, but
		# Prewikka WSGI module will handle it if not.
		#
		#<Location /prewikka>
		#        SetHandler None
		#</Location>
		#
		# Alias /prewikka /usr/share/prewikka/htdocs

		# For inclusion of a non-default configuration file
		# SetEnv PREWIKKA_CONFIG /etc/prewikka/prewikka.conf

		WSGIDaemonProcess prelude user=prewikka group=prelude
		WSGIProcessGroup prelude

		WSGIApplicationGroup %{GLOBAL}
		WSGIScriptAlias / /usr/share/prewikka/prewikka.wsgi

		ErrorLog logs/prelude.error
		CustomLog logs/prelude.log common

		<Directory "/usr/share/prewikka">
				Require all granted
		</Directory>
</VirtualHost>
EOF

cat << "EOF" > /etc/prewikka/prewikka.conf
##########################
# Prewikka configuration
##########################

[general]
# Number of heartbeats to analyze in the heartbeat analysis view.
#heartbeat_count: 30

# If the offset between two heartbeats is off by more than the specified
# offset (in seconds), the analyzer will be represented as offline.
#heartbeat_error_margin: 3

# Open external (references, IP lookup, and port lookup) links
# in a new windows.
external_link_new_window: yes

# Enables details links (default: no)
enable_details: no
# Enable error traceback (default: yes)
enable_error_traceback: yes
# URL to get details about an host
host_details_url: http://www.prelude-siem.com/host_details.php
# URL to get details about a port
port_details_url: http://www.prelude-siem.com/port_details.php
# URL to get details about a classification reference
reference_details_url: http://www.prelude-siem.com/reference_details.php

# When a defined number of classification, source, or target exceed
# the default value (10), an expension link will be provided to lookup
# the remaining entry.
#
#max_aggregated_source: 10
#max_aggregated_target: 10
#max_aggregated_classification: 10

# Asynchronous DNS resolution (require twisted.names and twisted.internet)
#
# While rendering view containing address scheduled for asynchronous
# DNS resolution, it is possible that the rendering terminate too fast
# for all DNS requests to complete.
#
# The dns_max_delay setting determine Prewikka behavior:
# - [-1] No DNS resolution is performed.
# - [0] Do not wait, immediatly send results to the client.
# - [x] Wait at most x seconds, then send results to the client.
#
# dns_max_delay: 0


# Default locale to use (default is English)
# The supported locales are : de_DE, en_GB, es_ES, fr_FR, it_IT, pl_PL, pt_BR, ru_RU
#
# default_locale: en_GB

# Default theme to use (default is cs)
# The supported themes are : blue, bright, classic, cs, dark, green, yellow
#
# default_theme: cs

# Default view to load after a successful login
# default_view: alerts/alerts

# Default encoding to use (default is UTF8):
# encoding: utf8

# Default section_order to use
# section_order: my_section

# Public path to Prewikka in case the application is being served
# through a reverse proxy, including any necessary port information.
# reverse_path: http://example.com/proxied/prewikka/

# Specify the section's order in left menu
#
# Use section: icon to add an icon
# All the icons available are here (v4.5):
# https://fortawesome.github.io/Font-Awesome/icons/
#
[section_order]
ALERT: exclamation-triangle
Alerts
Agents
ADMIN: sliders
Settings


[interface]
# Software name displayed in the top left corner (displays logo if not defined)
# software: Prelude

# Webpage title
# browser_title: Prelude OSS


#####################
# Customizable links
#####################

# [url host]
# label: http://url?host=$host

# [url classification]
# label: http://url?classification=$classification

# [url time]
# label: http://url?host=$host&time=$time


############
# Databases
############

# Events DB
[idmef_database]
# type: pgsql | mysql | sqlite3
# For sqlite, add
# file: /path/to/your/sqlite_database
#
type: mysql
host: __PRELUDEDB_HOST__
user: __PRELUDEBD_USER__
pass: __PRELUDEDB_PASSWD__
name: __PRELUDEDB_NAME__

# Prewikka DB
[database]
type: mysql
host: __PREWIKKA_HOST__
user: __PREWIKKA_USER__
pass: __PREWIKKA_PASSWD__
name: __PREWIKKA_NAME__


##########
# Logging
##########
# - You can activate several log section.
# - Log level might be set to all/debug, info, warning, error, critical.
#   If unspecified, the default level is "warning".

# [log stderr]
# level: info

# [log file]
# level: debug
# file: /tmp/prewikka.log

[log syslog]
level: info

# [log nteventlog]
# level: info

# [log smtp]
# level: warning
# host: mail.domain.com
# from: user@address
# to: recipient1@address, recipient2@address, recipientN@address
# subject: Subject to use


[include]
conf.d/*.conf
EOF

groupadd prelude
useradd --system prewikka -g prelude

systemctl enable httpd
systemctl start httpd
