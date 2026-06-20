#!/usr/bin/env bash
#
# lf previewer — kitty graphics for images/video/pdf/office, syntax-highlighted
# text, rich metadata, with graceful fallbacks. Tuned for macOS + kitty.
#
# Called by lf as:  scope.sh <file> <width> <height> <x> <y>
# lf exit codes:    0 show stdout · 1 no preview · 2 plain text
#                   5 show stdout (and never reload)

set -o noclobber -o noglob -o nounset -o pipefail

FILE="$1"
W="${2:-80}"; H="${3:-25}"; X="${4:-0}"; Y="${5:-0}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/lf"
mkdir -p -- "$CACHE_DIR"

# --- helpers ---------------------------------------------------------------

has() { command -v "$1" >/dev/null 2>&1; }

# Resolve a working `kitten` invocation once. Inside a kitty session it is on
# PATH; otherwise fall back to the app bundle (kitty is installed via Nix).
KITTEN=""
if has kitten; then
  KITTEN="kitten"
elif [ -x "/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten" ]; then
  KITTEN="/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten"
elif has kitty; then
  KITTEN="kitty +kitten"
fi

# Cache path for a generated thumbnail, keyed by device+inode+mtime so it is
# regenerated whenever the source file changes. (macOS `stat -f`.)
cache_for() {
  local key
  key="$(stat -f '%d-%i-%m' -- "$1" 2>/dev/null)" || return 1
  printf '%s/%s.jpg' "$CACHE_DIR" "$key"
}

# Draw an image in the preview pane, then stop (image persists until cleaner).
draw() {
  if [ -n "$KITTEN" ]; then
    # Inside tmux, draw via Unicode placeholders + tmux passthrough: the image
    # is bound to text cells, so lf's normal pane redraw erases it on the next
    # preview. The old direct-placement path relied on a delete escape that tmux
    # mangled — that is what left "garbage" from previous previews on screen.
    # (string, not array: keep working under macOS bash 3.2 + `set -u`.)
    pt=""
    [ -n "${TMUX:-}" ] && pt="--unicode-placeholder --passthrough tmux"
    if $KITTEN icat --stdin no --transfer-mode memory $pt \
        --place "${W}x${H}@${X}x${Y}" "$1" </dev/null >/dev/tty 2>/dev/null; then
      exit 1
    fi
  fi
  if has chafa; then
    chafa --format symbols --animate off --size "${W}x$((H - 1))" -- "$1" && exit 0
  fi
  return 1
}

# Generate a thumbnail once via $2(src,out) and draw it. No-op on failure.
thumb() {
  local out
  out="$(cache_for "$1")" || return 1
  [ -s "$out" ] || { "$2" "$1" "$out" || return 1; }
  draw "$out"
}

gen_video() { ffmpegthumbnailer -i "$1" -o "$2" -s 1024 -q 8 >/dev/null 2>&1; }
gen_svg()   { magick -background none -density 192 -- "$1" "$2" >/dev/null 2>&1; }
gen_pdf()   { pdftoppm -png -singlefile -r 144 -- "$1" "${2%.jpg}" >/dev/null 2>&1 \
                && mv -f "${2%.jpg}.png" "$2"; }
gen_ql() {  # macOS Quick Look — covers office docs, ebooks, many odd formats
  local dir produced
  dir="$(dirname "$2")"
  qlmanage -t -s 1024 -o "$dir" "$1" >/dev/null 2>&1 || return 1
  produced="$dir/$(basename "$1").png"
  [ -f "$produced" ] && mv -f "$produced" "$2"
}

show_text() {
  if has bat; then
    bat --color=always --style=plain --paging=never --wrap=never \
      --terminal-width="$W" -- "$1" && exit 5
  elif has highlight; then
    highlight --out-format=xterm256 --force --line-length="$W" -- "$1" && exit 5
  fi
  exit 2   # let lf render plain text itself
}

show_meta() {
  if has mediainfo; then mediainfo -- "$1"
  elif has exiftool; then exiftool -- "$1"
  else file -Lb -- "$1"; fi
  exit 5
}

list_archive() {
  has atool && atool --list -- "$1" 2>/dev/null && exit 5
  bsdtar --list --file "$1" 2>/dev/null && exit 5
  has 7z && 7z l -p -- "$1" 2>/dev/null && exit 5
  has lsar && lsar -- "$1" 2>/dev/null && exit 5
  exit 1
}

# --- dispatch --------------------------------------------------------------

MIME="$(file -Lb --mime-type -- "$FILE" 2>/dev/null)"
EXT="$(printf '%s' "${FILE##*.}" | tr '[:upper:]' '[:lower:]')"

case "$MIME" in
  inode/directory)
    if has eza;  then eza -la --tree --level=1 --color=always --icons -- "$FILE"
    elif has tree; then tree -L 1 -C -- "$FILE"
    else ls -la -- "$FILE"; fi
    exit 0 ;;
  image/svg+xml)
    has magick && thumb "$FILE" gen_svg
    thumb "$FILE" gen_ql
    show_text "$FILE" ;;
  image/*)
    draw "$FILE"
    thumb "$FILE" gen_ql
    show_meta "$FILE" ;;
  video/*)
    has ffmpegthumbnailer && thumb "$FILE" gen_video
    thumb "$FILE" gen_ql
    show_meta "$FILE" ;;
  audio/*)
    thumb "$FILE" gen_ql      # embedded cover art, if any
    show_meta "$FILE" ;;
  application/pdf)
    has pdftoppm && thumb "$FILE" gen_pdf
    thumb "$FILE" gen_ql
    has pdftotext && { pdftotext -l 10 -nopgbrk -q -- "$FILE" - | fmt -w "$W" && exit 5; }
    show_meta "$FILE" ;;
  application/json|*/json|*/xml|*/*+xml|*/javascript|*/x-shellscript)
    show_text "$FILE" ;;
  text/*)
    show_text "$FILE" ;;
esac

case "$EXT" in
  a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|\
  t7z|tar|tbz|tbz2|tgz|tlz|txz|tz|tzo|war|xpi|xz|z|zip|zst|7z)
    list_archive "$FILE" ;;
  doc|docx|xls|xlsx|ppt|pptx|odt|ods|odp|key|pages|numbers|rtf|epub|mobi|azw3|fb2)
    thumb "$FILE" gen_ql
    has pandoc && { pandoc -s -t plain -- "$FILE" 2>/dev/null | head -n 300 && exit 5; }
    show_meta "$FILE" ;;
  torrent)
    has transmission-show && { transmission-show -- "$FILE" && exit 5; }
    show_meta "$FILE" ;;
esac

# Fallback: file type + metadata.
echo "── $(basename -- "$FILE")"
file -Lb -- "$FILE" 2>/dev/null
echo
ls -ldh -- "$FILE" 2>/dev/null
has exiftool && { echo; exiftool -- "$FILE" 2>/dev/null; }
exit 0
