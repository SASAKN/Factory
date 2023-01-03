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
echo "Systemdをインストールします。"
apt-get install -y libterm-readline-gnu-perl systemd-sysv
dbus-uuidgen >/etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
apt-get -y upgrade

#パッケージをインストール
apt-get update
echo "現在、パッケージをインストールしています。"
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
echo "Linuxカーネルをインストールしています。"
apt install -y --no-install-recommends linux-generic-hwe-22.04

#Ubiquityインストール
echo "操作が必要な項目があります。"
echo "Ubiquityをインストールしています。"
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

#デスクトップ環境を整備
echo "デスクトップ環境をインストールしています。"
apt-get install -y \
    plymouth-theme-ubuntu-logo \
    ubuntu-gnome-desktop \
    ubuntu-gnome-wallpapers

#便利なパッケージのインストール
echo "便利なものをインストールしています。"
apt-get install -y \
    clamav-daemon \
    terminator \
    apt-transport-https \
    curl \
    vim \
    nano \
    less

#日本語環境の整備
echo "日本語環境をインストールしています。"
apt-get install -y \
    task-japanese \
    task-japanese-desktop \
    fcitx \
    fcitx-mozc
apt install -y --no-install-recommends `check-language-support -l ja`

#Javaインストール
echo "Javaをインストールしています。"
apt-get install -y \
    openjdk-8-jdk \
    openjdk-8-jre

#パッケージのアンインストール
echo "いらないものをアンインストールしています。"
apt-get purge -y \
    transmission-gtk \
    transmission-common \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori
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
