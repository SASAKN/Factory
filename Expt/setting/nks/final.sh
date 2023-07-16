#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#Install  Desktop Theme
apt-get install materia-kde -y

#Install Start up sounds
apt-get install alsa-utils -y

#Install Introduction movie
apt-get install mpv -y

#Install wallpaper
cd /root/deb
dpkg -i ./nks-wallpaper.deb

#NKSOSのブートスプラッシュに変更
cd /root/command
#update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/nksos/nksos.plymouth 100

#NKSOSのブート画面に変更
cd /root/file
mv grub.txt grub
cp grub /etc/default/grub
