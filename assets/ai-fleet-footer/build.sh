#!/bin/bash
# Regenerate every AI Fleet PR-footer asset in this folder from the launcher icon candidates.
# Usage: AI_FLEET=<path to a joshmouch/ai-fleet checkout> ./build.sh
# Reads palettes.tsv (candidate file stem, variant name, banner background, accent, tagline colour) and writes, per row,
# logo-<name>.png (64 px, rounded-square cut-out) and banner-<name>.svg (the logo at 128 px embedded). Needs ffmpeg.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
C=${AI_FLEET:?set AI_FLEET to a joshmouch/ai-fleet checkout}/engine/assets/desktop-accounts/candidates
M=$C/support/portrait-rounded-square-alpha.png   # the launcher lab's rounded-square mask
TAG="People and agents, one crew."
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
while IFS=$'\t' read -r file name bg accent sub; do
  [ -n "$file" ] && [ "${file#\#}" = "$file" ] || continue
  cut() { ffmpeg -loglevel error -y -i "$C/$file.png" -i "$M" -filter_complex "[1]format=gray[m];[0]format=rgba[i];[i][m]alphamerge,scale=$1:$1" "$2"; }
  cut 64 "$here/logo-$name.png"; cut 128 "$tmp/$name-128.png"
  B64=$(base64 < "$tmp/$name-128.png" | tr -d '\n')
  cat > "$here/banner-$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="640" height="64" viewBox="0 0 640 64" role="img" aria-label="Open Agency AI Fleet. $TAG">
  <rect width="640" height="64" rx="8" fill="$bg"/>
  <image x="10" y="8" width="48" height="48" xlink:href="data:image/png;base64,$B64"/>
  <text x="72" y="30" font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif" font-size="19" font-weight="600" fill="#EFEDE4">Open Agency AI Fleet</text>
  <text x="72" y="50" font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif" font-size="13" fill="$sub">$TAG</text>
  <rect x="620" y="16" width="4" height="32" rx="2" fill="$accent"/>
</svg>
SVG
  echo "$name"
done < "$here/palettes.tsv"
