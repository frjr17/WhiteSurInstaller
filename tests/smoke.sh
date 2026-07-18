#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly REPO_DIR
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "${TEST_DIR}"' EXIT

mkdir -p "${TEST_DIR}/bin" "${TEST_DIR}/home" "${TEST_DIR}/run"
export TEST_LOG="${TEST_DIR}/commands.log"

cat > "${TEST_DIR}/bin/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
dest="${*: -1}"
if [[ ${dest} == https://* ]]; then
  dest="${dest##*/}"
  dest="${dest%.git}"
fi
mkdir -p "${dest}"
printf '#!/usr/bin/env bash\nprintf "%%s:%%s\\n" "$PWD" "$*" >> "$TEST_LOG"\n' > "${dest}/install.sh"
printf '#!/usr/bin/env bash\nprintf "%%s:%%s\\n" "$PWD" "$*" >> "$TEST_LOG"\n' > "${dest}/tweaks.sh"
printf '#!/usr/bin/env bash\nprintf "%%s:%%s\\n" "$PWD" "$*" >> "$TEST_LOG"\n' > "${dest}/install-gnome-backgrounds.sh"
chmod +x "${dest}"/*.sh
printf 'clone:%s\n' "${dest}" >> "${TEST_LOG}"
EOF

cat > "${TEST_DIR}/bin/sudo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
"$@"
EOF

for command in dnf flatpak gsettings; do
  cat > "${TEST_DIR}/bin/${command}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s:%s\n' "${0##*/}" "$*" >> "${TEST_LOG}"
EOF
  chmod +x "${TEST_DIR}/bin/${command}"
done

cat > "${TEST_DIR}/bin/xrandr" <<'EOF'
#!/usr/bin/env bash
if [[ -n ${XRANDR_FAIL:-} ]]; then
  exit 1
fi
printf '%s\n' "${XRANDR_OUTPUT:-DP-1 connected primary 2560x1440+0+0}"
EOF

chmod +x "${TEST_DIR}/bin/git" "${TEST_DIR}/bin/sudo" "${TEST_DIR}/bin/xrandr"

(
  cd "${TEST_DIR}/run"
  PATH="${TEST_DIR}/bin:/usr/bin:/bin" HOME="${TEST_DIR}/home" bash "${REPO_DIR}/install.sh"
)

grep -Fq ':-c light -c dark -o solid --darker -l' "${TEST_LOG}"
grep -Fq ':-t whitesur -s 2k' "${TEST_LOG}"
grep -Fq 'gsettings:set org.gnome.desktop.interface gtk-theme WhiteSur-Light-solid' "${TEST_LOG}"

resolution="$(PATH="${TEST_DIR}/bin:/usr/bin:/bin" XRANDR_OUTPUT='DP-1 connected primary 3840x2160+0+0' "${REPO_DIR}/screen-res.sh")"
[[ ${resolution} == 4k ]]
resolution="$(PATH="${TEST_DIR}/bin:/usr/bin:/bin" XRANDR_FAIL=1 "${REPO_DIR}/screen-res.sh")"
[[ ${resolution} == 1080p ]]

while IFS= read -r clone_dir; do
  [[ ! -e ${clone_dir} ]]
done < <(sed -n 's/^clone://p' "${TEST_LOG}")

echo "Smoke test passed"
