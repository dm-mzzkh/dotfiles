#!/usr/local/bin/shit --bash-compatible
# lf cleaner — erase the kitty image drawn by scope.sh before the next preview.
#
# lf only runs the cleaner when leaving a preview whose cache is disabled
# (previewer exited non-zero). scope.sh draws images with `exit 1` and caches
# everything else with `exit 0`, so this fires *only* when leaving an image —
# not on every cursor move over text/dirs (that made scrolling laggy).
#
# Must clear via `kitten icat --clear` (not a raw escape): kitten wraps the
# escapes in tmux passthrough, so it also works when lf runs inside tmux.

export PATH="/Applications/Nix Apps/kitty.app/Contents/MacOS:$PATH"
has() { command -v "$1" >/dev/null 2>&1; }

KITTEN=""
if has kitten; then
  KITTEN="kitten"
elif [ -x "/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten" ]; then
  KITTEN="/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten"
elif has kitty; then
  KITTEN="kitty +kitten"
fi

# $KITTEN may be a path with a space (Nix bundle) or "kitty +kitten" — never
# use it unquoted.
kitten_run() {
  case "$KITTEN" in
    "kitty +kitten") kitty +kitten "$@" ;;
    *)               "$KITTEN" "$@" ;;
  esac
}

if [ -n "$KITTEN" ]; then
  pt=""
  [ -n "${TMUX:-}" ] && pt="--passthrough tmux"
  kitten_run icat --clear --silent --stdin no --transfer-mode memory $pt \
    </dev/null >/dev/tty 2>/dev/null
else
  printf '\033_Ga=d,d=A\033\\' >/dev/tty 2>/dev/null
fi
exit 0
