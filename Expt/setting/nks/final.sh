#################################################################
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#Install Desktop Theme
apt-get install materia-kde -y

#Install Icon
cd /root/file

#圧縮ファイルの解凍
xz -dv ./icons.tar.xz
tar xfv ./icons.tar -C /usr/share/icons/

#Tarを展開
tar xfv icons.tar -C /usr/share/icons/

#Install Cursors
cd /root/file
tar -zxvf cursors.tar.gz

#Install latte dock
apt-get install -y latte-dock

#Install aplay for playing boot sound.
apt-get install alsa-utils -y

#Install MPV Player for playing introduction movie.
apt-get install mpv -y

#Install Software Center
apt-get install plasma-discover -y

#Install Konsole
apt-get install konsole -y

#Install Super Tux Cart game
apt-get install supertuxcart -y

#install M plus fonts
apt-get install fonts-mplus -y
add-apt-repository --remove universe -y

#Copy necessary files.
cd /root/
cp -a ./nks/ /nks

#OSの基本情報ファイルのコピー
cp -f /root/nks/os-release /etc/os-release
cp -f /root/nks/os-release /usr/lib/os-release
cp -f /root/nks/kcm-about-distrorc /etc/xdg/kcm-about-distrorc

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
cp -r ./nks-grub /boot/grub/themes/nks-grub 
mv grub.txt grub
cp grub /etc/default/grub

#Grubの更新
update-grub

#SDDMの設定
cd /root/file
cp -r ./nks-sddm /usr/share/sddm/themes/nks-sddm
sudo sed -i 's/Current=.*/Current=nks-sddm/' /etc/sddm.conf

#FireFoxをインストール
source /root/file/firefox.sh