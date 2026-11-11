#!/bin/bash
# Regenerate every AI Fleet PR-footer asset in this folder from the launcher icon candidates.
# Usage: AI_FLEET=<path to a joshmouch/ai-fleet checkout> ./build.sh
# Reads palettes.tsv (candidate file stem, variant name, banner background, accent, tagline colour) and writes, per row,
# logo-<name>.png (64 px, rounded-square cut-out), banner-<name>.svg (640 x 64, the logo at 128 px embedded) and
# side-<name>.svg (128 x 200 panel for the high-visibility card's left column: the logo, then WORDS one per line). Needs ffmpeg.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
C=${AI_FLEET:?set AI_FLEET to a joshmouch/ai-fleet checkout}/engine/assets/desktop-accounts/candidates
M=$C/support/portrait-rounded-square-alpha.png   # the launcher lab's rounded-square mask
TAG="People and agents, one crew."
WORDS=(Plan. Build. Prove. Together.)   # the side panel's tagline, one word per line; the last in the accent colour
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
  lines=""; y=118
  for i in "${!WORDS[@]}"; do fill=$sub; [ "$i" -eq $(( ${#WORDS[@]} - 1 )) ] && fill=$accent
    lines="$lines  <text x=\"64\" y=\"$y\" text-anchor=\"middle\" font-family=\"-apple-system,Segoe UI,Helvetica,Arial,sans-serif\" font-size=\"16\" font-weight=\"600\" fill=\"$fill\">${WORDS[$i]}</text>
"; y=$(( y + 21 )); done
  cat > "$here/side-$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="200" viewBox="0 0 128 200" role="img" aria-label="Open Agency and AI Fleet: ${WORDS[*]}">
  <rect width="128" height="200" rx="10" fill="$bg"/>
  <image x="24" y="14" width="80" height="80" xlink:href="data:image/png;base64,$B64"/>
$lines</svg>
SVG
  echo "$name"
done < "$here/palettes.tsv"
