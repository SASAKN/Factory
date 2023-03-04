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
apt-get install $(cat /root/deps.list)

#カーネルをインストール
echo "Linuxカーネルをインストールしています。"
apt install -y --no-install-recommends linux-generic-hwe-22.04

#インストーラーをインストール
apt install -y $(cat /root/installer.list)

#デスクトップ環境を整備
echo "デスクトップ環境をインストールしています。"
apt-get install -y $(cat /root/de.list)

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

#Javaインストール
echo "Javaをインストールしています。"
apt-get install -y \
    openjdk-8-jdk \
    openjdk-8-jre

#パッケージのアンインストール
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