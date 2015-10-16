#!/bin/bash
#
# 0x776b7364
#
# This script helps to automate the installation of Oracle DB binaries to support
# the running of some of the database tools in Kali, such as metasploit and hexorbase. 
#
# You will need to specify your own zip file (ORACLECLIENTZIPURL) which should contain 
# the following 3 files (or similar):
# - instantclient-basic-linux.x64-12.1.0.2.0.zip
# - instantclient-sdk-linux.x64-12.1.0.2.0.zip
# - instantclient-sqlplus-linux.x64-12.1.0.2.0.zip
#
# The OIC file referenced in this script is password-protected due to 
# license issues - sorry!
#
# Tested on Kali 2.0 x64
#
# References:
#  https://github.com/rapid7/metasploit-framework/wiki/How-to-get-Oracle-Support-working-with-Kali-Linux
#  http://leonjza.github.io/blog/2014/08/17/kali-linux-oracle-support/
#  https://github.com/savio-code/hexorbase/blob/master/HexorBase/Oracle-API-installation.txt

function echoColour() {
	tput setaf 1;
	tput bold;
	echo -e "\n[*] $1";
	tput sgr0;
}

echoColour "Setting local variables ..."
ORACLECLIENTZIPURL=https://www.dropbox.com/s/w03aetlh75rru7n/OIC_x64-12.1.0.2.0.zip?dl=1
RUBYOCI8URL=https://github.com/kubo/ruby-oci8/archive/ruby-oci8-2.1.7.zip
CXURL=https://pypi.python.org/packages/source/c/cx_Oracle/cx_Oracle-5.2.tar.gz
WORKINGDIR=/opt/oracle/

echoColour "Creating working directory ..."
mkdir $WORKINGDIR
cd $WORKINGDIR

echoColour "Downloading required files ..."
wget $ORACLECLIENTZIPURL -O OIC_x64-12.1.0.2.0.zip
wget $RUBYOCI8URL
wget $CXURL

echoColour "Unzipping downloaded files ..."
echoColour "Enter password when prompted."
unzip $(ls -1 OIC*.zip)
for f in instantclient-*.zip; do unzip $f; done
unzip $(ls ruby-oci8-*.zip)
tar -xvf $(ls cx_Oracle*.tar.gz)

echoColour "Setting more local variables ..."
OICDIR=$WORKINGDIR$(ls -1 -d */ | grep instant)
RUBYDIR=$WORKINGDIR$(ls -1 -d */ | grep ruby)
CXDIR=$WORKINGDIR$(ls -1 -d */ | grep cx_Oracle)

echoColour "Performing linking ..."
cd $OICDIR
ln -s $(ls libclntsh.so*) libclntsh.so

echoColour "Writing environment variables to terminal session ..."
export PATH=$PATH:$OICDIR
export SQLPATH=$OICDIR
export TNS_ADMIN=$OICDIR
export LD_LIBRARY_PATH=$OICDIR
export ORACLE_HOME=$OICDIR

echoColour "Writing environment variables to .bashrc ..."
echo "export PATH=$PATH:$OICDIR" >> ~/.bashrc
echo "export SQLPATH=$OICDIR" >> ~/.bashrc
echo "export TNS_ADMIN=$OICDIR" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$OICDIR" >> ~/.bashrc
echo "export ORACLE_HOME=$OICDIR" >> ~/.bashrc

echoColour "Updating apt ..."
apt-get update -q

echoColour "Installing required packages ..."
apt-get install -q -y ruby-dev libgmp-dev build-essential python-dev libaio-dev

echoColour "Installing oci8 ..."
cd $RUBYDIR
make
make install

echoColour "Writing to oracle.conf ..."
echo "$OICDIR" >> /etc/ld.so.conf.d/oracle.conf

echoColour "Refreshing ldconfig ..."
ldconfig

echoColour "Installing cx_Oracle ..."
cd $CXDIR
python setup.py build
python setup.py install

echoColour "Done. Note that a logoff-logon cycle may be required for components to work correctly."