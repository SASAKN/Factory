#!/bin/bash
#sudoコマンドを使用しないで中身を書かないと、OSの作成が、失敗します。

#Start Settings
echo "Starting..."
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
os_aptrepo="http://jp.archive.ubuntu.com/ubuntu"
os_codename="jammy"
cd $HOME

#Loading COnfig File
source /root/config.sh

#Setting variable
username="honeylinux"
hostname="honey-linux"

#Setting Hostname
echo $hostname > /etc/hostname

#Adding Repository
   cat <<EOF > /etc/apt/sources.list
deb ${os_aptrepo} ${os_codename} main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename} main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-security main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-security main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
EOF

#Update
apt-get update

#Fixing Bug
chown root:root /

#Install Systemd
apt-get install -y libterm-readline-gnu-perl systemd-sysv

#Setting Machine ID
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

#Setting apt package
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#Install Deps Package
apt-get update
apt-get install -y $(cat /root/deps.list)

#Install Kernel
echo "Linuxカーネルをインストールしています。"
apt-get install -y --no-install-recommends $kernel

#Install installer
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

#Install your operating system packages
apt-get install -y $(cat /root/package.list)

#Package  Uninstall
apt-get autoremove -y

#Make Setting

#Locales
sudo dpkg-reconfigure locales

#resolvconf
dpkg-reconfigure resolvconf

#NetworkManager
cp -f /root/file/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
dpkg-reconfigure network-manager

#ファイナルステップを実行
bash /root/final.sh
apt-get update

#掃除
truncate -s 0 /etc/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
apt-get clean
rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0
exit