#Apply Wallpaper
script_dir="$(dirname "$(readlink -f "$0")")"
source ${script_dir}/config.sh
cd ${script_dir}/setting/${setting_name}/deb
dpkg -i ./nks-wallpaper.deb
bash ./plasma-apply-wallpaperimage /usr/share/wallpapers/nks-wallpaper/contents/screenshot.png