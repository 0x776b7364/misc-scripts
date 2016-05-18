#!/bin/sh -e
set -x
# Local customization
uid=1000
gid=1000
arch=amd64
release=squeeze

# Default values
# $1 d-i iso image file
# $2 d-i ro mount point
# $3 d-i rw tree

di_iso=${1:-d-i.iso}
di_ro=${2:-d-i.ro}
di_rw=${3:-d-i.rw}

cat > config << EOF
Dir {
    ArchiveDir ".";
    OverrideDir ".";
    CacheDir ".";
 };
            
 TreeDefault {
    Directory "pool/";
 };
                    
 BinDirectory "pool/main" {
    Packages "dists/${release}/main/debian-installer/binary-${arch}/Packages";
 };
                                   
 Default {
    Packages {
        Extensions ".udeb";
    };
 };
EOF

cd $di_rw
sudo apt-ftparchive generate ../config
sudo md5sum $(find ! -name "md5sum.txt" ! -path "./isolinux/*" -follow -type f) > md5sum.txt
cd -

#genisoimage ...
sudo genisoimage -r -o $di_iso -V di$(date -u +%m%d%H%M%S) \
   -b isolinux/isolinux.bin -c isolinux/boot.cat \
   -no-emul-boot -boot-load-size 4 -boot-info-table $di_rw

# check mounted by "mount"
#sudo umount ${di_rw}
#sudo umount ${di_ro}
#rm -rf $di_rw