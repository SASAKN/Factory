#!/bin/bash
#sudoコマンドを使用しないで中身を書かないと、OSの作成が、失敗します。

#開始するための設定
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
cd $HOME

sleep -s 5

#変数の設定
hostname="honey-linux"

sleep -s 5

#hostname設定
echo $hostname > /etc/hostname

#リポジトリの追加
   cat <<EOF > /etc/apt/sources.list
deb http://jp.archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu jammy main restricted universe multiverse

deb http://jp.archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse

deb http://jp.archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb-src http://jp.archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
EOF

#アップデート
apt-get update

#systemdインストール
# we need to install systemd first, to configure machine id
apt-get update
#Must!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
chown root:root /
apt-get install -y libterm-readline-gnu-perl systemd-sysv
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#パッケージをインストール
apt-get update
echo "現在、パッケージをインストールしています。"
apt-get install $(cat /root/deps.list)
sleep -s 5

#カーネルをインストール
echo "Linuxカーネルをインストールしています。"
apt install -y --no-install-recommends linux-generic-hwe-22.04

#インストーラーをインストール
apt install -y \
    ubiquity \
    ubiquity-casper \
    ubiquity-frontend-gtk \
    ubiquity-frontend-kde \
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
cp -f /root/file/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
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
