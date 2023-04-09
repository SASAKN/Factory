#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

apt install initramfs-tools
cat <<EOF > /etc/casper.conf
# This file should go in /etc/casper.conf
# Supported variables are:
# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM
export USERNAME="${username}"
export USERFULLNAME="${userfullname}"
export HOST="${username}"
export BUILD_SYSTEM="Ubuntu"
export FLAVOUR="${username}"
EOF
chmod 775 /usr/share/initramfs-tools/scripts/casper-bottom/*adduser
chmod 775 /usr/share/initramfs-tools/scripts/casper-bottom/*autologin
mkinitramfs -o /boot/initrd.img-`uname -r` `uname -r`
#終わり
exit 0
