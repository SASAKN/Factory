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
apt-get install -y $(cat /root/deps.list)

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