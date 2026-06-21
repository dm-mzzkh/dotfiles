#!/usr/local/bin/shit --bash-compatible
#
# ranger-style tabs for lf (which has none natively). Each lf instance keeps a
# list of "tab" directories; switching cd's the single pane and redraws a tab
# bar into promptfmt. State is per-instance, keyed by lf's $id.
#
# usage: tabs.sh <action> <id> <pwd> [n]
#   sync         persist current dir into the active tab and redraw the bar
#   new          open a new tab at the current dir
#   close        close the active tab
#   switch <n>   jump to tab n
#   next | prev  cycle tabs
#
set -u

action="${1:-sync}"; id="${2:-0}"; cwd="${3:-$PWD}"; arg="${4:-}"

state="${TMPDIR:-/tmp}/lf-tabs"
mkdir -p "$state"
T="$state/tabs.$id"   # one directory per line, line N = tab N
C="$state/cur.$id"    # active tab index

# drop this instance's state on quit, before the init below recreates it
[ "$action" = clean ] && { rm -f "$T" "$C"; exit 0; }

[ -s "$T" ] || printf '%s\n' "$cwd" > "$T"
[ -s "$C" ] || printf '1\n' > "$C"

count() { grep -c '' "$T"; }
cur()   { cat "$C"; }
line()  { sed -n "${1}p" "$T"; }
set_line() { awk -v n="$1" -v v="$2" 'NR==n{print v;next}{print}' "$T" >"$T.t" && mv "$T.t" "$T"; }
del_line() { awk -v n="$1" 'NR!=n' "$T" >"$T.t" && mv "$T.t" "$T"; }
remote() { lf -remote "send $id $*" 2>/dev/null || true; }

render() {
  local n c i=0 d name bar="" e
  e=$(printf '\033')           # real ESC byte — avoids relying on lf to parse \033
  n=$(count); c=$(cur)
  while IFS= read -r d; do
    i=$((i + 1)); name=$(basename "$d")
    if [ "$i" = "$c" ]; then bar="$bar ${e}[1;7m $i $name ${e}[0m"
    else                     bar="$bar ${e}[2m $i $name ${e}[0m"; fi
  done < "$T"
  remote "set promptfmt \"$bar  ${e}[34;1m%w${e}[0m%S${e}[2m [$c/$n] ${e}[0m\""
}

case "$action" in
  sync)
    set_line "$(cur)" "$cwd"; render ;;
  new)
    printf '%s\n' "$cwd" >> "$T"; count > "$C"; render ;;
  switch)
    set_line "$(cur)" "$cwd"
    n=$(count)
    case "$arg" in (*[!0-9]*|'') exit 0;; esac
    [ "$arg" -ge 1 ] && [ "$arg" -le "$n" ] || exit 0
    printf '%s\n' "$arg" > "$C"
    remote "cd \"$(line "$arg")\""; render ;;   # render too: cd is a no-op if same dir
  next|prev)
    set_line "$(cur)" "$cwd"
    n=$(count); c=$(cur)
    if [ "$action" = next ]; then c=$(( c % n + 1 )); else c=$(( (c - 2 + n) % n + 1 )); fi
    printf '%s\n' "$c" > "$C"
    remote "cd \"$(line "$c")\""; render ;;
  close)
    n=$(count)
    if [ "$n" -le 1 ]; then remote 'echo only one tab'; exit 0; fi
    c=$(cur); del_line "$c"
    n=$(count); [ "$c" -gt "$n" ] && c="$n"
    printf '%s\n' "$c" > "$C"
    remote "cd \"$(line "$c")\""; render ;;
esac
