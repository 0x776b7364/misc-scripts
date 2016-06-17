#!/bin/bash

# tested on Kali 201601 Rolling x86
# working as of 21 Mar 2016
# run this script as root
# allow 45 minutes for installation
# non-interactive except for Passenger installation portion (25 minutes from script execution) and Redis installation portion (45 minutes from script execution)
# inspiration from:
# - https://sathisharthars.wordpress.com/2014/07/02/installing-phishing-frenzy-in-kali-linux/
# - https://www.phishingfrenzy.com/resources/install_kali_linux
# - http://www.thehackspace.org/showthread.php?tid=17
# - https://hub.docker.com/r/b00stfr3ak/ubuntu-phishingfrenzy/builds/bpgnkhkisuvw8nchbdjwpzk/

FQDN="phishing-frenzy.local"
CURRENTIP="$(hostname -i)"

echo "[*] Clone Repo …"
git clone https://github.com/pentestgeek/phishing-frenzy.git /var/www/phishing-frenzy

echo "[*] Install RVM, Ruby and Packages …"
\curl -sSL https://get.rvm.io | bash
source /etc/profile.d/rvm.sh
rvm pkg install openssl
rvm install 2.1.5 --with-openssl-dir=/usr/local/rvm/usr
rvm all do gem install --no-rdoc --no-ri rails
rvm all do gem install --no-rdoc --no-ri passenger

echo "[*] Install Passenger …"
apt-get update
apt-get install -y apache2-dev libcurl4-openssl-dev
leafpad /etc/apache2/apache2.conf &

echo "The Passenger Apache module will be installed next. Follow the instructions to copy the LoadModule text stated into apache2.conf, then save the edits."
echo "The Python option in the installation can be deselected."
read -p "Press [Enter] key to continue."

passenger-install-apache2-module

echo "[*] Apache VHOST Configuration …"
echo >> /etc/apache2/apache2.conf
echo "Include pf.conf" >> /etc/apache2/apache2.conf

apt-get install -y libmysqlclient-dev
touch /etc/apache2/pf.conf

# 'PassengerRoot' and 'PassengerRuby' values should follow the ones in apache2.conf
cat > /etc/apache2/pf.conf << EOL
  <IfModule mod_passenger.c>
    PassengerRoot /usr/local/rvm/gems/ruby-2.1.5/gems/passenger-5.0.26
    PassengerRuby /usr/local/rvm/gems/ruby-2.1.5/wrappers/ruby
  </IfModule>

  <VirtualHost *:80>
    ServerName $FQDN
    # !!! Be sure to point DocumentRoot to 'public'!
    DocumentRoot /var/www/phishing-frenzy/public
    RailsEnv development
    <Directory /var/www/phishing-frenzy/public>
      # This relaxes Apache security settings.
      AllowOverride all
      # MultiViews must be turned off.
      Options -MultiViews
    </Directory>
  </VirtualHost>
EOL

echo "[*] MySQL …"
service mysql start
# kali by default uses blank mysql root passwords
mysql -uroot --password="" -e "create database pf_dev"
mysql -uroot --password="" -e "grant all privileges on pf_dev.* to 'pf_dev'@'localhost' identified by 'password'"

echo "[*] Install Required Gems …"
cd /var/www/phishing-frenzy/
bundle install
bundle exec rake db:migrate
bundle exec rake db:seed

echo "[*] Install Redis …"
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
cd redis-stable/
make
make install
cd utils/
./install_server.sh

echo "[*] Sidekiq Configuration …"
mkdir -p /var/www/phishing-frenzy/tmp/pids
cd /var/www/phishing-frenzy
bundle exec sidekiq -C config/sidekiq.yml &

echo "[*] System Configuration …"
echo "www-data ALL=(ALL) NOPASSWD: /etc/init.d/apache2 reload" >> /etc/sudoers
bundle exec rake templates:load
chown -R www-data:www-data /var/www/phishing-frenzy/
chmod -R 755 /var/www/phishing-frenzy/public/uploads/
chown -R www-data:www-data /etc/apache2/sites-enabled/
chmod -R 755 /etc/apache2/sites-enabled/
chown -R www-data:www-data /etc/apache2/sites-available/

echo "$CURRENTIP $FQDN"  >> /etc/hosts

apachectl start

echo "Login with admin : Funt1me!"
iceweasel "http://$FQDN"
