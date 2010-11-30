#! /bin/sh
apt-get -y install squashfs-tools genisoimage
wget -O chroot.sh http://pwiki.grimp.eu/tools/code.php?p=Linux/1.0/build/chroot.sh
chmod +x chroot.sh


# PRE-CHROOT

mkdir ./livecdtmp
mv ./*.iso ./livecdtmp/originale.iso
cd ./livecdtmp/
mkdir mnt
mount -o loop originale.iso mnt
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
unsquashfs mnt/casper/filesystem.squashfs
mv squashfs-root edit

#internet
cp /etc/resolv.conf edit/etc/
cp /etc/hosts edit/etc/ #ricordarsi di rimuoverlo

mount --bind /dev/ edit/dev
cp ../chroot.sh edit/chroot.sh

#Repo
rm -rf edit/etc/apt/sources.list
rm -rf edit/etc/apt/sources.list.d/*
wget -O edit/etc/apt/sources.list http://pwiki.grimp.eu/tools/code.php?p=Linux/1.0/apt/sources.list

# CHROOT
chroot edit ./chroot.sh

# POST-CHROOT
rm -rf edit/chroot.sh
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

#rm extract-cd/casper/filesystem.squashfs
mksquashfs edit extract-cd/casper/filesystem.squashfs

rm -rf extract-cd/README.diskdefines

echo "#define DISKNAME  Ubuntu Grimp Remix 2.0 - Release i386" > extract-cd/README.diskdefines
echo "#define TYPE  binary" >> extract-cd/README.diskdefines
echo "#define TYPEbinary  1" >> extract-cd/README.diskdefines
echo "#define ARCH  i386" >> extract-cd/README.diskdefines
echo "#define ARCHi386  1" >> extract-cd/README.diskdefines
echo "#define DISKNUM  1" >> extract-cd/README.diskdefines
echo "#define DISKNUM1 1" >> extract-cd/README.diskdefines
echo "#define TOTALNUM  0" >> extract-cd/README.diskdefines
echo "#define TOTALNUM0  1" >> extract-cd/README.diskdefines

cd extract-cd
rm md5sum.txt

find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../grimp.iso .
