#設定を読み込む
#ベースのOSリポジトリー
os_repository="http://jp.archive.ubuntu.com/ubuntu"

#ベースのコードネーム
os_codename="jammy"

#OSの名前
os_name="Honey Linux"

#OSのCPU
os_arch="amd64"

#OSのインストールラベル
os_label1="Open NKSOS boot selection screen"
os_label2="Start in Developer Mode"
os_label3="Check Disk"
os_label4="Memory Test (Legacy)"
os_label5="Memory Test(UEFI)"

#ビルド番号
buildid="A1"

#設定の名前
setting_name="nks"

###Expt
echo "これは、実験的な実装です。"

#カーネルのパッケージ名
kernel="linux-generic"

#Live環境から離れた時の削除処理
remove_package="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"
username="honeylinux"
hostname="honey-linux"
userfullname="HoneyLinux Tester"