#! /bin/sh

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
apt-get --quiet update
add-apt-repository ppa:grimp/grimp
wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list &&  apt-get --quiet update &&  apt-get --yes --quiet --allow-unauthenticated install medibuntu-keyring && apt-get --quiet update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y install grimp-desktop grimp-restricted-extras grimp-desktop-languages-support
apt-get upgrade
#google-talk-videochat-plugin TESTING
wget http://dl.google.com/linux/direct/google-talkplugin_current_i386.deb
dpkg -i google-talkplugin_current_i386.deb
rm -rf google-talkplugin_current_i386.deb 

#Firefox-homepage TESTING
echo 'pref("browser.startup.homepage", "file:/etc/xul-ext/grimp-homepage.properties");' >> /etc/xul-ext/ubufox.js
echo 'browser.startup.homepage=http://start.grimp.eu/2' > /etc/xul-ext/grimp-homepage.properties

#Italian - TESTING
#locale-gen it
#update-locale LANG=it_IT.UTF-8 LANGUAGE=it_IT.UTF-8 LC_ALL=it_IT.UTF-8

#Cleanup
apt-get clean
rm -rf /tmp/* ~/.bash_history
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
rm /etc/resolv.conf
rm /etc/hosts
umount -lf /proc
umount -lf /sys
umount -lf /dev/pts

