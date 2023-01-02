#基本的に変更しない（スクリプト保存場所の設定）
script_dir=$(cd $(dirname $0); pwd)

#ベースのOSリポジトリー
os_repository=""

#ベースのコードネーム
os_codename="jammy"

#OSの名前
os_name="HoneyLinux"

#OSのCPU
os_arch="amd64"

#OSのインストールラベル
os_label1="HoneyLinuxを試します"
os_label2="HoneyLinuxをインストールします"
os_label3="ディスクをチェックします"
os_label4="メモリーをテスト(レガシー)"
os_label5="メモリーをテスト(UEFI)"

#ビルド番号
buildid="A1"

#設定の名前
setting_name="honey"