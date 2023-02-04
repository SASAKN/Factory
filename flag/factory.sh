#!/bin/bash

#基本的に変更しない（スクリプト保存場所の設定）
script_dir="$(dirname "$(readlink -f "$0")")"

#設定をロードする。
source ${script_dir}/config.sh

#必要なディレクトリー作成
cd ${script_dir}
mkdir image
mkdir out
mkdir chroot

#依存関係のインストール
source ${script_dir}/deps.sh

#ベースを作る
cd ${script_dir}
sudo debootstrap \
   --arch=$os_arch \
   --variant=minbase \
   $os_codename \
   chroot \
   $os_repository

#設定ファイルのコピー
sudo cp -a ${script_dir}/setting/${setting_name}/file/ ${script_dir}/chroot/root/file/
sudo cp -a ${script_dir}/setting/${setting_name}/copyfs/ ${script_dir}/chroot/root/copyfs/
sudo cp ${script_dir}/setting/${setting_name}/chroot.sh ${script_dir}/chroot/root/chroot.sh
sudo cp ${script_dir}/setting/${setting_name}/final.sh ${script_dir}/chroot/root/final.sh
sudo cp ${script_dir}/setting/${setting_name}/deps.list ${script_dir}/chroot/root/deps.list
sudo cp ${script_dir}/setting/${setting_name}/de.list ${script_dir}/chroot/root/de.list
sudo cp ${script_dir}/setting/${setting_name}/installer.list ${script_dir}/chroot/root/installer.list
sudo cp ${script_dir}/config.sh ${script_dir}/chroot/root/config.sh

#ファイルシステムのマウント
sudo mount --bind /dev chroot/dev
sudo mount --bind /run chroot/run

#スクリプト実行
cd ${script_dir}
sudo chroot chroot bash /root/chroot.sh

#マウントを解除
sudo umount chroot/dev
sudo umount chroot/run

exit 0