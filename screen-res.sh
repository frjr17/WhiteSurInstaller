#!/usr/bin/env bash

set -euo pipefail

screen=""
if command -v xrandr >/dev/null 2>&1; then
  if ! screen="$(xrandr --current 2>/dev/null | awk '
    / connected primary / { print $4; found = 1; exit }
    / connected / && !fallback { fallback = $3 }
    END { if (!found && fallback) print fallback }
  ')"; then
    screen=""
  fi
fi

height="${screen#*x}"
height="${height%%+*}"

if [[ ${height} =~ ^[0-9]+$ ]] && ((height >= 2160)); then
  echo "4k"
elif [[ ${height} =~ ^[0-9]+$ ]] && ((height >= 1440)); then
  echo "2k"
else
  echo "1080p"
fi
