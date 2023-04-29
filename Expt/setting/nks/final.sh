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

#NKSOSのに変更
