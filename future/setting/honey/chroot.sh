#!/bin/bash
#===========Do not write "sudo" in this script.===========#

#===========Start Setting===========#
echo "Starting..."
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
os_aptrepo="http://jp.archive.ubuntu.com/ubuntu"
os_codename="jammy"
cd $HOME

#===========Read Settings===========#
source /root/config.sh

#===========Setting Hostname===========#
echo $hostname > /etc/hostname

#===========Add Repository===========#
   cat <<EOF > /etc/apt/sources.list
deb ${os_aptrepo} ${os_codename} main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename} main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-security main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-security main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
EOF

#===========Update===========#
apt-get update
#===========Fix Bugs===========#
chown root:root /

#===========Install Systemd===========#
apt-get install -y libterm-readline-gnu-perl systemd-sysv

#===========Setting Machine-ID===========#
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

#===========Dpkg setting===========#
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#===========Install Deps Packages===========#
apt-get update
apt-get install -y $(cat /root/deps.list)

#===========Install Kernel===========#
echo "Linuxカーネルをインストールしています。"
apt-get install -y --no-install-recommends $kernel

#===========Task Automation===========#

#===========Install Automating Tools===========#
apt-get install -y debconf-utils expect

#===========Disable interactive environment===========#
DEBIAN_FRONTEND=noninteractive

#===========Configuration debconf===========#
echo $(cat /root/debconf.config) | debconf-set-selections

#===========Install Ubiquity===========#
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

#===========Install Packages(Application Software)===========#

#===========Install your own system packages.===========#
apt-get install -y $(cat /root/package.list)

#===========Uninstall no need packages.===========#
apt-get autoremove -y

#===========Write Settings File===========#
#networkmanager
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
#Make Setting

#Locales
rm "/etc/locale.gen"
dpkg-reconfigure -f noninteractive locales

#resolvconf
/usr/bin/expect<<EOF
spawn dpkg-reconfigure -f readline resolvconf
expect "updates?" { send "Yes\r" }
EOF

#NetworkManager
apt-get install netplan.io
dpkg-reconfigure -f noninteractive network-manager

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