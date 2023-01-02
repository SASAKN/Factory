################################################################# 
# ファイナルステップへようこそ！              　　　　　　　　　　　　　　#
#　ここに、OS独自のファイルをコピーするなどの編集を加えてください。        #
#################################################################

#変数の設定
hostname="honey-linux"
username="honeylinux"

#ユーザーの追加
useradd $username
echo "パスワードを決めてください。"
passwd $username



#起動の再設定
update-alternatives --config default.plymouth
#終わり
exit 0