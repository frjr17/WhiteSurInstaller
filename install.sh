#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly REPO_DIR

if [[ ! -f /etc/os-release ]]; then
  echo "Cannot detect the operating system: /etc/os-release is missing." >&2
  exit 1
fi

# Provided by systemd on supported systems.
# shellcheck disable=SC1091
source /etc/os-release

if [[ ${ID} != fedora ]]; then
  echo "WhiteSurInstaller currently supports Fedora only (detected: ${PRETTY_NAME})." >&2
  exit 1
fi

echo "Detected OS: ${PRETTY_NAME}"

# Component installers own their build dependencies. This wrapper only needs
# the tools it uses directly.
sudo dnf install -y git flatpak

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.mattjakeman.ExtensionManager

"${REPO_DIR}/whitesur.sh"

sudo flatpak override \
  --filesystem=xdg-config/gtk-3.0 \
  --filesystem=xdg-config/gtk-4.0

gsettings set org.gnome.desktop.interface cursor-theme WhiteSur-cursors
gsettings set org.gnome.desktop.interface icon-theme WhiteSur-light
gsettings set org.gnome.desktop.interface gtk-theme WhiteSur-Light-solid
