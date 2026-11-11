#!/bin/bash
# Regenerate every AI Fleet PR-footer asset in this folder from the launcher icon candidates.
# Usage: AI_FLEET=<path to a joshmouch/ai-fleet checkout> ./build.sh
# Reads palettes.tsv (candidate file stem, variant name, banner background, accent, tagline colour) and writes, per row,
# logo-<name>.png (64 px, rounded-square cut-out), banner-<name>.svg (640 x 64, the logo at 128 px embedded) and
# tile-<name>.svg (the standard card's left column: the background colour with the logo at the top; it has no fixed size,
# so it fills whatever width and height the footer's <img> gives it) and side-<name>.svg (112 x 160 panel for the
# high-visibility card's left column: the logo, then WORDS one per line). Needs ffmpeg.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
C=${AI_FLEET:?set AI_FLEET to a joshmouch/ai-fleet checkout}/engine/assets/desktop-accounts/candidates
M=$C/support/portrait-rounded-square-alpha.png   # the launcher lab's rounded-square mask
TAG="People and agents, one crew."
WORDS=(Plan. Build. Prove. Together.)   # the side panel's tagline, one word per line; the last is the emphasis
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
  cat > "$here/tile-$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" role="img" aria-label="Open Agency and AI Fleet">
  <rect width="100%" height="100%" rx="8" fill="$bg"/>
  <image x="50%" y="8" width="48" height="48" transform="translate(-24 0)" xlink:href="data:image/png;base64,$B64"/>
</svg>
SVG
  # The leading words are small and muted, left-aligned under the logo; the last word is the one emphasis.
  lines=""; y=110; last=$(( ${#WORDS[@]} - 1 ))
  for i in "${!WORDS[@]}"; do
    if [ "$i" -eq "$last" ]; then y=$(( y + 4 ))
      lines="$lines  <text x=\"16\" y=\"$y\" font-family=\"-apple-system,Segoe UI,Helvetica,Arial,sans-serif\" font-size=\"15\" font-weight=\"600\" fill=\"$accent\">${WORDS[$i]}</text>
"
    else
      lines="$lines  <text x=\"16\" y=\"$y\" font-family=\"-apple-system,Segoe UI,Helvetica,Arial,sans-serif\" font-size=\"10\" fill=\"$sub\" fill-opacity=\"0.7\">${WORDS[$i]}</text>
"; y=$(( y + 13 ))
    fi
  done
  cat > "$here/side-$name.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="112" height="160" viewBox="0 0 112 160" role="img" aria-label="Open Agency and AI Fleet: ${WORDS[*]}">
  <rect width="112" height="160" rx="10" fill="$bg"/>
  <image x="16" y="12" width="80" height="80" xlink:href="data:image/png;base64,$B64"/>
$lines</svg>
SVG
  echo "$name"
done < "$here/palettes.tsv"
