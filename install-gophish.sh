#!/bin/bash

# tested on Kali 2016.2 Rolling x86
# working as of 29 Sep 2016
# run this script as root
# allow 10 minutes for installation
# requires about 400MB of HDD space
# inspiration from:
# - https://github.com/gophish/gophish/blob/master/README.md#building-from-source

echo "[*] Install golang …"
apt-get update
apt-get install -y golang
export GOPATH=$HOME/.go

echo "[*] Clone repo …"
go get -v github.com/gophish/gophish

echo "[*] Build gophish …"
cd $GOPATH/src/github.com/gophish/gophish/
go build -v

echo "[*] Modify gophish config …"
# to listen on all interfaces
sed -i 's/127.0.0.1/0.0.0.0/' $GOPATH/src/github.com/gophish/gophish/config.json

echo "[*] Launch gophish …"
echo "Login with admin : gophish"
./gophish &
/etc/alternatives/x-www-browser http://127.0.0.1:3333 &
