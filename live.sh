#bin/bash
####LiveBuild System Setting File
#これは、デスクトップテーマなどを変える時にしか使えません。
cd /root/file
#Install wallpaper
cd /usr/share/wallpapers
mkdir nkswallpaper-old
mkdir nks-wallpaper
cd /root/file
cp -r ./nkswallpaper-old /usr/share/wallpapers/
cp -r ./nks-wallpaper /usr/share/wallpapers/ 

#NKSOSのブートスプラッシュに変更
cd /root/command
#update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/nksos/nksos.plymouth 100

#Grubの設定
cd /root/file/
cd /usr/share/grub/
mkdir -p ./themes/nks-grub/
cd /root/file/
cp -r /root/file/nks-grub /usr/share/grub/themes/
mv /root/file/grub.txt /root/file/grub
cp /root/file/grub /etc/default/grub
update-grub

#インストールスライドの変更
cd /root/file
cp -pR ./nks-slide/* /usr/share/ubiquity-slideshow/

#SDDMの設定
cd /root/file
mkdir -p /usr/share/sddm/themes
cp -r ./nks-sddm/ /usr/share/sddm/themes/
sed -i 's/Current=.*/Current=nks-sddm/' /etc/sddm.conf
cd /etc/
mkdir sddm.conf.d
cd /root/file/
cp /root/file/sddm.conf /etc/sddm.conf.d/kde_settings.conf

#Plasma グローバルテーマを作成。
cd /usr/share/plasma/
mkdir -p look-and-feel
cd /root/file
cp -r /root/file/com.nksteam.nksos/ /usr/share/plasma/look-and-feel/

#FireFoxをインストール
source /root/file/firefox.sh

#Pacupのインストール
cd /root/file
cp ./pacup /usr/bin/pacup
cp ./pacup /bin/pacup
cp ./pacup /usr/local/bin/pacup

#Unifetchのインストール
cd /root/file
cp ./unifetch /usr/bin/unifetch
cp ./unifetch /bin/unifettch
cp ./unifetch /usr/local/bin/unifetch