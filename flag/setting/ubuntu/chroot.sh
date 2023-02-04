#!/bin/bash
#sudoコマンドを使用しないで中身を書かないと、OSの作成が、失敗します。

#開始するための設定
echo "Starting..."
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
os_aptrepo="http://jp.archive.ubuntu.com/ubuntu"
os_codename="jammy"
cd $HOME
touch resolvconf
touch locales
touch network-manager
touch keyboard-configuration
touch console-setup

echo "Ready Go !"

#変数の設定
username="honeylinux"
hostname="honey-linux"

#hostname設定
echo $hostname > /etc/hostname

#リポジトリの追加
   cat <<EOF > /etc/apt/sources.list
deb ${os_aptrepo} ${os_codename} main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename} main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-security main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-security main restricted universe multiverse

deb ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
deb-src ${os_aptrepo} ${os_codename}-updates main restricted universe multiverse
EOF

#アップデート
apt-get update

#バグ修正
chown root:root /

#Systemdをインストール
apt-get install -y libterm-readline-gnu-perl systemd-sysv

#マシンIDを設定する。
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

#パッケージを使えるようにする。
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#パッケージをインストール
apt-get update
echo "現在、パッケージをインストールしています。"
apt-get install -y \
    sudo \
    ubuntu-standard \
    casper \
    lupin-casper \
    discover \
    laptop-detect \
    os-prober \
    network-manager \
    resolvconf \
    net-tools \
    wireless-tools \
    wpagui \
    locales \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common

#インストーラーをインストール
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

#設定を取得
debconf-get-selections | grep keyboard-configuration >> keyboard-configuration
debconf-get-selections | grep console-setup >> console-setup
#カーネルをインストール
echo "Linuxカーネルをインストールしています。"
apt-get install -y --no-install-recommends linux-generic

#Debconf収集
apt-get install debconf-utils grep -y

#パッケージのアンインストール
apt-get autoremove -y


#ファイルのコピーと設定
dpkg-reconfigure locales
#設定を取得
debconf-get-selections | grep locales >> locales
dpkg-reconfigure resolvconf
#設定を取得
debconf-get-selections | grep resolvconf >> resolvconf
cp -f /root/file/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
dpkg-reconfigure network-manager
#設定を取得
debconf-get-selections | grep network-manager >> network-manager 

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