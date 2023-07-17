#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#Install Desktop Theme
apt-get install materia-kde -y

#Install aplay for playing boot sound.
apt-get install alsa-utils -y

#Install MPV Player for playing introduction movie.
apt-get install mpv -y

#Copy necessary files.
cd /root/
cp -a ./nks/ /nks

#Copy skelton files.
cd /root/
cp -a ./skel/ /etc/

#Install wallpaper
cd /root/deb
dpkg -i ./nks-wallpaper.deb

#NKSOSのブートスプラッシュに変更
cd /root/command
#update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/nksos/nksos.plymouth 100

#NKSOSのブート画面に変更
cd /root/file
cp -r ./nks-grub /boot/grub/themes/ 
mv grub.txt grub
cp grub /etc/default/grub
