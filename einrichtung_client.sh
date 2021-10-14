!/bin/bash
apt install curl
echo -e "PubkeyAuthentication yes \nPasswordAuthentication yes \nAuthorizedKeysCommand /usr/local/bin/userkeys.sh \nAuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
touch /usr/local/bin/userkeys.sh
echo "#!/bin/bash" >> /usr/local/bin/userkeys.sh
echo "curl -sf https://raw.githubusercontent.com/Hobbabobba/keyserver/main/\$1/keys" >> /usr/local/bin/userkeys.sh
chmod a+x /usr/local/bin/userkeys.sh
service ssh restart
echo "FERTIG"
