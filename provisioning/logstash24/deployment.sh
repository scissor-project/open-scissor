#!/bin/bash -x

umask 022

source /tmp/scissor-log.sh

NODE_NAME="logstash24"
hostnamectl set-hostname $NODE_NAME
# replace default 'ubuntu' name with our new hostname in /etc/hosts
sed -i "/127\.0\.1\.1/ s/ubuntu\$/$NODE_NAME/" /etc/hosts

cd /etc/logstash/conf.d
git clone -b logstash24 https://anc-git.salzburgresearch.at/gkatzinger/logstash-config.git .
log "Cloned logstash-config"

FLUME_IP="10.10.1.54"
DATASOURCE24_IP="10.10.1.51"
STREAMON_IP="10.10.1.64"
CAMERA_IP="10.10.1.240"

sed -i "s/10\.0\.1\.12/$FLUME_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\.0\.1\.9/$STREAMON_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\.0\.1\.200/$CAMERA_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\.0\.1\.11/$DATASOURCE24_IP/g" /etc/logstash/conf.d/syslogng.conf

#TLS block
cd /root
mkdir pd
cd pd
mkdir beats
mkdir logstash
mkdir ca

# Renew TLS keys and certs using PKCS8 format
project="/root/pd"
ipAdd=$NODE_NAME

# CA BUILD
# private key generation
openssl genrsa 2048 > $project/ca/ca.key

# X509 cert generation
openssl req -new -x509 -key $project/ca/ca.key -subj '/C=FR/ST=Yvelines/L=Sqy/O=Assystem/OU=Cyber/CN=CA' > $project/ca/ca.crt

# LOGSTASH SERVER CERT
# private key generation
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform pem -outform pem -nocrypt > $project/logstash/logstash.key

# cert request
openssl req -new -key $project/logstash/logstash.key -subj '/C=FR/ST=Yvelines/L=Sqy/O=Assystem/OU=Cyber/CN=Logstash' > $project/logstash/logstash.csr

# cert signature
openssl x509 -req -in $project/logstash/logstash.csr -out $project/logstash/logstash.crt -CA $project/ca/ca.crt -extfile <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=IP:"$ipAdd)) -extensions SAN -CAkey $project/ca/ca.key -CAcreateserial -CAserial $project/ca/ca.srl
openssl x509 -in $project/logstash/logstash.crt -noout -text

rm $project/logstash/*.csr

# BEATS SERVER CERT
# private key generation
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform pem -outform pem -nocrypt > $project/beats/beats.key

# cert request
openssl req -new -key $project/beats/beats.key -subj '/C=FR/ST=Yvelines/L=Sqy/O=Assystem/OU=Cyber/CN=Beats' > $project/beats/beats.csr

# cert signature
openssl x509 -req -in $project/beats/beats.csr -out $project/beats/beats.crt -CA $project/ca/ca.crt -CAkey $project/ca/ca.key -CAcreateserial -CAserial $project/ca/ca.srl
openssl x509 -in $project/beats/beats.crt -noout -text

rm $project/beats/*.csr

cp $project/ca/ca.crt $project/beats/ca.crt
cp $project/ca/ca.crt $project/logstash/ca.crt

/opt/logstash/bin/logstash -f /etc/logstash/conf.d/syslogng.conf >& /tmp/output.logstash &

log "Started logstash"

ds24_password="password"

sshpass -p $ds24_password scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $project/beats/ca.crt root@$DATASOURCE24_IP:/root/pd/beats/
sshpass -p $ds24_password scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $project/beats/beats.crt root@$DATASOURCE24_IP:/root/pd/beats/
sshpass -p $ds24_password scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $project/beats/beats.key root@$DATASOURCE24_IP:/root/pd/beats/

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux-config"

#Ensure that output files from logstash do not fill disk
echo "/tmp/logstash_output.txt {
        size 20M
        copytruncate
        rotate 4
}
" >> /etc/logrotate.conf
#Ensure that check for filesize is running each hour
cp /etc/cron.daily/logrotate /etc/cron.hourly

log "Host $NODE_NAME ready (attached to flume on ${FLUME_IP})"
