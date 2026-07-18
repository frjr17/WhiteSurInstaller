#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly REPO_DIR
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "${WORK_DIR}"' EXIT

git clone --depth=1 https://github.com/frjr17/WhiteSurCursors.git "${WORK_DIR}/WhiteSurCursors"
(cd "${WORK_DIR}/WhiteSurCursors" && ./install.sh)

git clone --depth=1 https://github.com/frjr17/WhiteSurIconTheme.git "${WORK_DIR}/WhiteSurIconTheme"
(cd "${WORK_DIR}/WhiteSurIconTheme" && ./install.sh)

git clone --depth=1 https://github.com/frjr17/WhiteSurGtkTheme.git "${WORK_DIR}/WhiteSurGtkTheme"
(
  cd "${WORK_DIR}/WhiteSurGtkTheme"
  ./install.sh -c light -c dark -o solid --darker -l
  sudo ./tweaks.sh -g -p 60
)

screen_resolution="$("${REPO_DIR}/screen-res.sh")"
echo "Your screen resolution variant is ${screen_resolution}"

git clone --depth=1 https://github.com/frjr17/WhiteSurWallpapers.git "${WORK_DIR}/WhiteSurWallpapers"
(
  cd "${WORK_DIR}/WhiteSurWallpapers"
  ./install-gnome-backgrounds.sh -t whitesur -s "${screen_resolution}"
)
