#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#NKSOS独自の壁紙に変更。
#Install wallpaper
cd /root/deb
dpkg -i ./nks-wallpaper.deb

#NKSOSのブートスプラッシュに変更
cd /root/command
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/nksos/nksos.plymouth 100

#NKSOSのブート画面に変更
cd /root/file
mv grub.txt grub
cp grub /etc/default/grub
update-grub
