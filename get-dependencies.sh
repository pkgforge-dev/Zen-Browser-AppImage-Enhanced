#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libcanberra

if [ "$ARCH" = 'x86_64' ]; then
	pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Getting binary..."
echo "---------------------------------------------------------------"
link=https://github.com/zen-browser/desktop/releases/download/1.21.1b/zen.linux-$ARCH.tar.xz

wget --retry-connrefused --tries=30 "$link" -O /tmp/tarball.tar.xz
mkdir -p ./AppDir/bin
tar xfv /tmp/tarball.tar.xz
mv -v ./zen/* ./AppDir/bin

cp -v ./AppDir/bin/browser/chrome/icons/default/default128.png ./AppDir/zen.png
cp -v ./AppDir/bin/browser/chrome/icons/default/default128.png ./AppDir/.DirIcon
rm -rf /tmp/tarball.tar.xz ./zen

awk -F'=' '/Version=/{print $2; exit}' ./AppDir/bin/application.ini > ~/version
