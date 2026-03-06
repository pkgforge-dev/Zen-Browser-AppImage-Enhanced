#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q zen-browser-bin | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=https://raw.githubusercontent.com/zen-browser/desktop/refs/heads/dev/build/AppDir/zen.desktop
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export ANYLINUX_LIB=1
export URUNTIME_PRELOAD=1

# Deploy dependencies
# for some reason we need to set LD_LIBRARY_PATH for zen to find its bundled libs
export LD_LIBRARY_PATH=$PWD/AppDir/bin 
quick-sharun \
	./AppDir/bin/*          \
	/usr/lib/libavcodec.so* \
	/usr/lib/libcanberra.so*
unset LD_LIBRARY_PATH

echo 'MOZ_LEGACY_PROFILES=1'        >> ./AppDir/.env
echo 'MOZ_APP_LAUNCHER=${APPIMAGE}' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
