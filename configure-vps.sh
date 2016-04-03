#!/bin/bash
# for Debian 8

# run this script as root
# execute as:
# root@debian:~# . ./vps-configure.sh

SSHPORT=12345
DROPBOXURL="https://www.dropbox.com/s/???/irssi_config.7z?dl=1"

# == add non-privileged user ==
read -p "Enter unprivileged user name to create: " USERNAME
adduser $USERNAME

# == apt-get operations ==
apt-get update
apt-get -y upgrade

# === no custom config files ===
apt-get install -y nano lsof locate screen ntp p7zip

# === has custom config files ===
apt-get install -y irssi fail2ban

# == TZ settings ==
#TZ='Asia/Singapore'
echo "[*] Configuring tzdata ..."
echo "Pacific/Auckland" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# == sshd settings ==
echo "[*] Modifying sshd_config ..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sed -i "s/Port 22/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

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
