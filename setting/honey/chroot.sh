#!/bin/bash
#sudoコマンドを使用しないで中身を書かないと、OSの作成が、失敗します。

#開始するための設定
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
cd $HOME

#変数の設定
hostname="honey-linux"

#hostname設定
echo $hostname > /etc/hostname

#リポジトリの追加
cp -f file/sources.list /etc/apt/sources.list

#アップデート
apt-get update

#systemdインストール
apt-get install -y libterm-readline-gnu-perl systemd-sysv
dbus-uuidgen >/etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
apt-get upgrade -y

#パッケージをインストール
apt-get update
apt-get install -y sudo \
    ubuntu-standard \
    casper \
    firefox-esr \
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
    grub2-common \
    task-kde-desktop \
    task-japanese \
    task-japanese-desktop \
    fcitx \
    fcitx-mozc \
    ffmpeg \
    xdg-utils \
    open-vm-tools \
    build-essential \
    gparted \
    alsa-utils \
    bluetooth \
    btrfs-progs \
    clamtk \
    curl \
    flatpak \
    gdebi

#カーネルをインストール
apt-get install -y --no-install-recommends linux-generic

#Ubiquityインストール

#ようこそ！操作へ
echo "操作が必要な項目があります。"

apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork
#OS固有パッケージアンインストール
apt-get purge -y 
apt-get autoremove -y


#ファイルのコピーと設定
dpkg-reconfigure locales
dpkg-reconfigure resolvconf
cp -f /file/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
dpkg-reconfigure network-manager

#ファイナルステップを実行
bash /root/final.sh

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
