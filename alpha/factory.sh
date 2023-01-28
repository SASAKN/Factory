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
#Minbaseをなしに。
cd ${script_dir}
sudo debootstrap \
   --arch=$os_arch \
   $os_codename \
   chroot \
   $os_repository

#設定ファイルのコピー
sudo cp -a ${script_dir}/setting/${setting_name}/file/ ${script_dir}/chroot/root/file/
sudo cp -a ${script_dir}/setting/${setting_name}/copyfs/ ${script_dir}/chroot/root/copyfs/
sudo cp ${script_dir}/setting/${setting_name}/chroot.sh ${script_dir}/chroot/root/chroot.sh
sudo cp ${script_dir}/setting/${setting_name}/final.sh ${script_dir}/chroot/root/final.sh
sudo cp ${script_dir}/setting/${setting_name}/sharepackages.list ${script_dir}/chroot/root/sharepackages.list
sudo cp ${script_dir}/setting/${setting_name}/packages.list ${script_dir}/chroot/root/packages.list
#ファイルシステムのマウント
sudo mount --bind /dev chroot/dev
sudo mount --bind /run chroot/run

#スクリプト実行
cd ${script_dir}
sudo chroot chroot bash /root/chroot.sh

#マウントを解除
sudo umount chroot/dev
sudo umount chroot/run

#ディレクトリーの作成
cd ${script_dir}
mkdir -p image/{casper,isolinux,install}

#カーネルイメージのコピー
sudo cp chroot/boot/vmlinuz-**-**-generic image/casper/vmlinuz
sudo cp chroot/boot/initrd.img-**-**-generic image/casper/initrd

#Memtest86+(BIOS)のコピー
sudo cp chroot/boot/memtest86+.bin image/install/memtest86+

#Memtest86(UEFI)のダウンロード
sudo wget --progress=dot https://www.memtest86.com/downloads/memtest86-usb.zip -O image/install/memtest86-usb.zip
sudo unzip -p image/install/memtest86-usb.zip memtest86-usb.img >image/install/memtest86
sudo rm -f image/install/memtest86-usb.zip

#Grubの設定
cd ${script_dir}
touch image/ubuntu

#Grub.cfgを書く
cat <<EOF > image/isolinux/grub.cfg

search --set=root --file /ubuntu

insmod all_video

set default="0"
set timeout=30

menuentry "${os_label1}" {
   linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
   initrd /casper/initrd
}

menuentry "${os_label2}" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}

menuentry "${os_label3}" {
   linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
   initrd /casper/initrd
}

menuentry "${os_label4}" {
   linux16 /install/memtest86+
}

menuentry "${os_label5}" {
   insmod part_gpt
   insmod search_fs_uuid
   insmod chain
   loopback loop /install/memtest86
   chainloader (loop,gpt1)/efi/boot/BOOTX64.efi
}
EOF

#マニフェスト作成
cd ${script_dir}
sudo chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest
sudo cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/discover/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/laptop-detect/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/os-prober/d' image/casper/filesystem.manifest-desktop

#OSを圧縮
sudo mksquashfs chroot image/casper/filesystem.squashfs

#filesystem.sizeの作成
printf $(sudo du -sx --block-size=1 chroot | cut -f1) >image/casper/filesystem.size

#インストールファイル作成
cd ${script_dir}
cat <<EOF >image/README.diskdefines
#define DISKNAME  ${os_name}
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

#UEFI GRUB image 作成
cd ${script_dir}/image
grub-mkstandalone \
   --format=x86_64-efi \
   --output=isolinux/bootx64.efi \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

#FAT16 UEFI image 作成
(
   cd isolinux &&
      dd if=/dev/zero of=efiboot.img bs=1M count=10 &&
      sudo mkfs.vfat efiboot.img &&
      LC_CTYPE=C mmd -i efiboot.img efi efi/boot &&
      LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
)

#BIOS用イメージ作成
grub-mkstandalone \
   --format=i386-pc \
   --output=isolinux/core.img \
   --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
   --modules="linux16 linux normal iso9660 biosdisk search" \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

#cdboot.img作成
cd ${script_dir}/image
cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img >isolinux/bios.img

#md5sumCheck!
cd ${script_dir}/image
sudo /bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'md5sum.txt' -e 'bios.img' -e 'efiboot.img' > md5sum.txt)"

#ISO作成
sudo xorriso \
   -as mkisofs \
   -iso-level 3 \
   -full-iso9660-filenames \
   -volid "${os_name}" \
   -output "../out/factory.iso" \
   -eltorito-boot boot/grub/bios.img \
   -no-emul-boot \
   -boot-load-size 4 \
   -boot-info-table \
   --eltorito-catalog boot/grub/boot.cat \
   --grub2-boot-info \
   --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
   -eltorito-alt-boot \
   -e EFI/efiboot.img \
   -no-emul-boot \
   -append_partition 2 0xef isolinux/efiboot.img \
   -m "isolinux/efiboot.img" \
   -m "isolinux/bios.img" \
   -graft-points \
   "/EFI/efiboot.img=isolinux/efiboot.img" \
   "/boot/grub/bios.img=isolinux/bios.img" \
   "."

#終わり
exit 0
