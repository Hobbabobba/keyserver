!/bin/bash
apt install curl wget
echo -e "PubkeyAuthentication yes \nPasswordAuthentication no \nAuthorizedKeysCommand /usr/local/bin/userkeys.sh \nAuthorizedKeysCommandUser nobody\nPubkeyAcceptedKeyTypes +ssh-rsa\nHostKeyAlgorithms +ssh-rsa" >> /etc/ssh/sshd_config
wget -P /usr/local/bin https://raw.githubusercontent.com/Hobbabobba/keyserver/main/userkeys.sh
chmod a+x /usr/local/bin/userkeys.sh
service ssh restart
echo "FERTIG"
