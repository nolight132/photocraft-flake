#!/usr/bin/env bash
# Points sources.json at the latest PhotoCraft release, using the hashes upstream publishes.
set -euo pipefail
cd "$(dirname "$0")"

tag=$(curl -fsSL https://api.github.com/repos/storytold/photocraft/releases/latest | jq -r .tag_name)
version=${tag#v}
sums=$(curl -fsSL "https://github.com/storytold/photocraft/releases/download/$tag/SHA256SUMS.txt")

sri() {
  local hex
  hex=$(awk -v f="photocraft-$version-linux-$1.tar.gz" '$2 == f { print $1 }' <<<"$sums")
  [[ -n $hex ]] || { echo "no checksum for $1 in $tag" >&2; exit 1; }
  nix hash convert --hash-algo sha256 --to sri "$hex"
}

jq -n --arg v "$version" --arg x "$(sri x86_64)" --arg a "$(sri aarch64)" \
  '{version: $v, hashes: {x86_64: $x, aarch64: $a}}' > sources.json
echo "photocraft $version"
