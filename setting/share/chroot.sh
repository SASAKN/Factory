#!/bin/bash
#sudoコマンドを使用しないで中身を書かないと、OSの作成が、失敗します。
#変数の設定
hostname="honey-linux"
#開始するための設定
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
cd $HOME
#aptコマンド設定 + アップグレード
cp -f file/sources.list /etc/apt/sources.list
apt-get update
apt-get install -y libterm-readline-gnu-perl systemd-sysv
dbus-uuidgen >/etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
apt-get upgrade -y
#必須パッケージインストール
apt-get install -y \
    sudo \
    ubuntu-standard \
    casper \
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
#カーネルをインストール
apt-get install -y --no-install-recommends linux-generic
#インストーラーをインストール
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk
apt-get install -y ./deb/installer/*.deb
#OS固有パッケージのインストール
apt-get install -y $(cat ./package.list)
apt-get install -y ./deb/software/*.deb
#OS固有ファイルのインストール
cp -RT -f copyfs/etc etc/
cp -RT -f copyfs/usr usr/
cp -RT -f copyfs/home home/
cp -RT -f copyfs/opt opt/
cp -RT -f copyfs/bin bin/
cp -RT -f copyfs/sbin sbin/
#推奨パッケージインストール
apt-get install -y \
    clamav-daemon \
    terminator \
    apt-transport-https \
    curl \
    vim \
    nano \
    less
#javaインストール
apt-get install -y \
    openjdk-8-jdk \
    openjdk-8-jre
#OS固有パッケージアンインストール
apt-get install -y $(cat ./remove.list)
apt-get autoremove -y
#言語の再設定
dpkg-reconfigure locales
#ネットワークの再設定
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
dpkg-reconfigure network-manager
#Plymouthの再設定
sudo update-alternatives --config default.plymouth
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