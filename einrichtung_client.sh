#!/bin/bash
rm /usr/local/bin/userkeys.sh
apt install wget
# Datei definieren
SSHD_CONFIG="/etc/ssh/sshd_config"
# Konfigurationszeilen definieren
CONFIG_LINES=(
    "PubkeyAuthentication yes"
    "PasswordAuthentication no"
    "AuthorizedKeysCommand /usr/local/bin/userkeys.sh"
    "AuthorizedKeysCommandUser nobody"
    "PubkeyAcceptedKeyTypes +ssh-rsa"
    "HostKeyAlgorithms +ssh-rsa"
)

# Schleife über jede Zeile
for line in "${CONFIG_LINES[@]}"; do
    # Überprüfen, ob die Zeile bereits in der Datei vorhanden ist
    if ! grep -Fxq "$line" "$SSHD_CONFIG"; then
        # Zeile anhängen, wenn sie noch nicht existiert
        echo "$line" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
done
wget -P /usr/local/bin https://raw.githubusercontent.com/Hobbabobba/keyserver/main/userkeys.sh
chmod a+x /usr/local/bin/userkeys.sh
service ssh restart
echo "SSH Zugang fertig"
