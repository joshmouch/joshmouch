# AI Fleet PR-footer assets

Public images for the footer atlas puts on every pull request it opens (`publicity.prFooter` in
`joshmouch/contributions` `atlas/bin/repo-config.json`). They live in this public repository because GitHub shows no
images from private repositories on another repository's PR, and doesn't render `data:` URIs.

| File | What |
|---|---|
| `logo-<name>.png` | 64 px logo, rounded-square cut-out with transparent corners, for the footer card |
| `banner-<name>.svg` | 640 × 64 banner (logo, "Open Agency AI Fleet", tagline), kept as an option |
| `side-<name>.svg` | 112 × 160 panel (logo, then a small left-aligned one-word-per-line tagline ending on the emphasised "Together.") for the high-visibility card's left column |
| `palettes.tsv` | one row per variant: candidate file stem, variant name, banner background, accent, tagline colour |
| `build.sh` | regenerates every file above from its source |

## Where the icons come from

Every logo is an AI Fleet launcher icon candidate. The candidates live in `joshmouch/ai-fleet` at
`engine/assets/desktop-accounts/candidates/` (sets 01 to 09; its `README.md` and `catalog.json` describe them).
The launcher's icon lab (`engine/assets/desktop-accounts/animation-prototypes/`, the Accounts launcher's
**Launch Icon Viewer**) shows them as rounded squares with transparent corners. `build.sh` produces the same
cut-out by applying the lab's mask, `candidates/support/portrait-rounded-square-alpha.png`, to each candidate.

Josh removed the octopus operator (08), the mixed agency group (12), the raven (05) and the front-facing wolf (07)
on 2026-11-11. The rotation is the rows of `palettes.tsv`.

## Adding or changing a variant

1. Pick a candidate from the sets above and add a row to `palettes.tsv`: its file stem (without `.png`), a short
   lower-case name, and three colours taken from the icon (a dark background, an accent, and a muted tagline colour).
2. Run `AI_FLEET=<path to an ai-fleet checkout> ./build.sh` (needs ffmpeg).
3. Commit the new and changed files. A PR's variant is chosen from the PR itself, so each PR keeps its logo.
