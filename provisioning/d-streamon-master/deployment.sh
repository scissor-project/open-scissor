#!/bin/bash -xe

# get parameters

# We don't need to login to clone from a public repo
#export bitbucket_username=""
#export bitbucket_password=""
export config_name=""

export ROOTPASSWD="scissormaster"
export USER="root"
export GIT_USER="Nofx"
export GIT_REP_NAME="d-streamon"
export HOME="/${USER}"
export STREAMON_ROOT="${HOME}/${GIT_REP_NAME}/streamon"
export NVM_DIR="${HOME}/.nvm"

export LOG="${HOME}/log"

# root password update
echo -e "$ROOTPASSWD\n$ROOTPASSWD\n" | sudo passwd root

# permit ssh password login
sed -i 's/prohibit-password/yes/g' /etc/ssh/sshd_config && /etc/init.d/ssh reload

# remove ssh host key checking
sed -i '/StrictHostKeyChecking/d' /etc/ssh/ssh_config && echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# create log
su -c 'touch ${LOG}' ${USER}

# create public/private rsa key pair
echo -e "\n\n\n" | ssh-keygen >> ${LOG}

# get the software
cd ${HOME}
#git clone https://${bitbucket_username}:${bitbucket_password}@bitbucket.org/${GIT_USER}/${GIT_REP_NAME}.git >> ${LOG}
# Clone the repository without logging in
git clone https://bitbucket.org/${GIT_USER}/${GIT_REP_NAME}.git >> ${LOG}

# build/install
cd ${STREAMON_ROOT}
cmake . >> ${LOG}
make >> ${LOG}

# nvm install
cd ${HOME}
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash >> ${LOG}
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" && nvm install v0.10.25 >> ${LOG}

# npm install
cd ${GIT_REP_NAME}
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" && npm install --unsafe-perm >> ${LOG}

# npm swagger and gulp
cd ${HOME}
npm install -g swagger
npm install -g gulp

# ansible configuration
mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.old
echo -e "[defaults]\nhost_key_checking = False" > /etc/ansible/ansible.cfg

# set a confortable color set to operate in vim
echo "colo desert" >> /root/.vimrc && echo "set number" >> /root/.vimrc

# set a confortable color of terminal
echo  "export LS_COLORS=\"no=00:fi=00:di=1;32:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=00;35:*.cmd=00;32:*.exe=00;32:*.sh=00;32:*.gz=00;31:*.bz2=00;31:*.bz=00;31:*.tz=00;31:*.rpm=00;31:*.cpio=00;31:*.t=93:*.pm=00;36:*.pod=00;96:*.conf=00;33:*.off=00;9:*.jpg=00;94:*.png=00;94:*.xcf=00;94:*.JPG=00;94:*.gif=00;94:*.pdf=00;91\"" >> /root/.bashrc

# start service"
# [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" && node ${HOME}/nuvla_master/bin/semaphore.js >> ${LOG} &"
