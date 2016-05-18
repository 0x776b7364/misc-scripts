#!/bin/sh -e

# Local customization to match your id (check with 'id' command).
uid=1000
gid=1000

# Default values
# $1 d-i iso image file
# $2 d-i ro mount point
# $3 d-i rw tree

di_iso=${1:-d-i.iso}
di_ro=${2:-d-i.ro}
di_rw=${3:-d-i.rw}

pwd=$(pwd)
timestamp=$(date -u +%Y%m%d%H%M%S)
mkdir $timestamp

mkdir $timestamp/$di_ro
mkdir $timestamp/$di_rw

sudo mount ${di_iso} $timestamp/${di_ro} -t iso9660 -o loop,uid=${uid},gid=${gid}
sudo mount -t aufs -o br:$timestamp/${di_rw}:$timestamp/${di_ro} none $timestamp/${di_rw}
sudo chmod u+w $timestamp/${di_rw}
sudo chmod u+w $timestamp/${di_rw}/md5sum.txt
sudo find $timestamp/${di_rw}/dists -exec chmod u+w {} \;
sudo find $timestamp/${di_rw}/pool  -type d -exec chmod u+w {} \;
cd $timestamp