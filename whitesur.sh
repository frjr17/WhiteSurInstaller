#!/bin/bash

set -e

scrDir="$(dirname "$(realpath "$0")")"
pm=$1

# Setting Cursor -----------------------------------------

git clone https://github.com/vinceliuice/WhiteSurCursors.git

cd WhiteSurCursors

./install.sh

cd ..

rm -rf WhiteSurCursors

# Setting Icon -------------------------------------------

git clone https://github.com/vinceliuice/WhiteSurIconTheme.git

cd WhiteSurIconTheme

./install.sh

cd ..

rm -rf WhiteSurIconTheme

# Setting Theme ------------------------------------------

git clone https://github.com/frjr17/WhiteSurGtkTheme.git

cd WhiteSurGtkTheme 

./install.sh -l -c light -m  -HD --round -N stable

sudo ./tweaks.sh -g -p 60

cd ..

rm -rf WhiteSurGtkTheme

mkdir -p ~/.themes

for i in "$scrDir"/theme/*;do
	tar -xf $i -C ~/.themes
done

# Setting walls

screen_resolution=$(./screen-res.sh)

git clone https://github.com/frjr17/WhiteSurWallpapers.git

cd WhiteSurWallpapers

mkdir -p ~/.local/share/gnome-background-properties

echo "Your Screen Resolution is $screen_resolution"

./install-gnome-backgrounds.sh -t whitesur -s "${screen_resolution}"

cd ..

rm -rf WhiteSurWallpapers

