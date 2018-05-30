#!/bin/bash
# for Debian 9

# run this script as root
# execute as:
# root@debian:~# wget https://raw.githubusercontent.com/0x776b7364/misc-scripts/master/configure-vps.sh
# root@debian:~# nano configure-vps.sh
# root@debian:~# . ./vps-configure.sh

# partially adapted from:
#  https://gist.github.com/marcy-terui/9460706

SSHPORT=12345
DROPBOXURL="https://www.dropbox.com/s/???/irssi_config.7z?dl=1"
KEY_FILENAME="id_ecdsa_vps"

# == add non-privileged user ==
read -p "Enter user name of new account: " USERNAME
adduser $USERNAME

# == apt-get operations ==
apt-get update
apt-get -y upgrade

# === no custom config files ===
apt-get install -y lsof locate screen ntp p7zip ssh

# === has custom config files ===
apt-get install -y irssi fail2ban

# == TZ settings ==
echo "[*] Configuring timezone ..."
timedatectl set-timezone Asia/Singapore

# == sshd settings ==
echo "[*] Modifying sshd_config ..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sed -i "s/#Port 22/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i "s/.*RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" /etc/ssh/sshd_config
sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

runuser -l $USERNAME -c 'mkdir /home/$USERNAME/.ssh'
runuser -l $USERNAME -c 'chmod 700 /home/$USERNAME/.ssh'
runuser -l $USERNAME -c 'ssh-keygen -t ecdsa -b 521 -N "" -f /home/$USERNAME/.ssh/$KEY_FILENAME'

cat /home/$USERNAME/.ssh/$KEY_FILENAME.pub > /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys

# == fail2ban settings ==
# manually set
echo "[*] Opening fail2ban jail.conf ..."
echo "[*] Edit 'port' and 'bantime' values in the [ssh] section"
echo "[ssh]"
echo "port = ssh,$SSHPORT"
echo "bantime = 1800"
read -p "[*] Press [Enter] to continue"
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.orig
nano /etc/fail2ban/jail.conf

# == irssi settings ==
# === retrieve external config file ===
echo "[*] Loading irssi config ..."
mkdir /home/$USERNAME/.irssi/
cd /home/$USERNAME/.irssi/
wget --no-check-certificate $DROPBOXURL -O /home/$USERNAME/.irssi/irssi_config.7z
7zr x /home/$USERNAME/.irssi/irssi_config.7z
rm /home/$USERNAME/.irssi/irssi_config.7z
chown -R $USERNAME:$USERNAME /home/$USERNAME/

echo "[*] Setting files world-readable ..."
chmod 644 /var/log/auth.log
chmod 644 /var/log/fail2ban.log

echo "[*] Restarting services ..."
service ssh restart
service fail2ban restart

echo "[*] Done!"
