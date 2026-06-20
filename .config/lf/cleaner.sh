#!/usr/bin/env bash
# lf cleaner — erase the kitty image drawn by scope.sh before the next preview.
#
# Must clear via `kitten icat --clear`, NOT a raw graphics escape: kitten wraps
# the escapes in tmux passthrough, so this also works when lf runs inside tmux,
# where a bare APC sequence written to the tty is swallowed and the image lingers.
# Keep --transfer-mode in sync with scope.sh's draw().

has() { command -v "$1" >/dev/null 2>&1; }

KITTEN=""
if has kitten; then
  KITTEN="kitten"
elif [ -x "/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten" ]; then
  KITTEN="/Applications/Nix Apps/kitty.app/Contents/MacOS/kitten"
elif has kitty; then
  KITTEN="kitty +kitten"
fi

if [ -n "$KITTEN" ]; then
  pt=""
  [ -n "${TMUX:-}" ] && pt="--passthrough tmux"
  $KITTEN icat --clear --silent --stdin no --transfer-mode memory $pt \
    </dev/null >/dev/tty 2>/dev/null
else
  # No kitten: only chafa symbol output was drawn, which lf redraws over.
  # Fall back to the protocol "delete all" in case kitty is the terminal.
  printf '\033_Ga=d,d=A\033\\' >/dev/tty 2>/dev/null
fi
exit 0
