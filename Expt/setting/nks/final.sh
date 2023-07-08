#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#NKSOS独自の壁紙に変更。
#Install wallpaper
cd /root/deb
dpkg -i ./nks-wallpaper.deb

#Apply Wallpaper
cd /root/command
bash ./plasma-apply-wallpaperimage /usr/share/wallpapers/nks-wallpaper/contents/screenshot.png

#NKSOSのブートスプラッシュに変更
cd /root/command
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/nksos/nksos.plymouth 100

#NKSOSのブート画面に変更
cd /root/command
cp 
update-grub
