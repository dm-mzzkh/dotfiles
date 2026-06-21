#!/usr/local/bin/shit --bash-compatible
#
# Test launcher for the lf config. Sources the per-area test files in tests/ and
# runs them, timing each test and the whole run. Fully isolated: each test uses
# its own temp dir with private XDG_DATA_HOME / XDG_CACHE_HOME / TMPDIR, so your
# real clipboard buffer, thumbnail cache, trash and running lf are never touched.
#
# Usage (from anywhere):
#   .config/lf/run.sh            run every test
#   .config/lf/run.sh paste      run only tests whose name contains "paste"
#   .config/lf/run.sh scope      ... (paste, extract, archive, scope, tabs, cleaner)
#
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"        # the lf config dir
JOB="$ROOT/job.sh"; SCOPE="$ROOT/scope.sh"; TABS="$ROOT/tabs.sh"; CLEAN="$ROOT/cleaner.sh"
export LF_NO_NOTIFY=1                         # silence macOS notifications during the run
FILTER="${1:-}"
pass=0; fail=0; skip=0
ESC="$(printf '\033')"; g="${ESC}[32m"; r="${ESC}[31m"; y="${ESC}[33m"; d="${ESC}[2m"; b="${ESC}[1m"; z="${ESC}[0m"

# ---- assertions (used by tests/*.sh) --------------------------------------
ok(){    pass=$((pass+1)); printf '  %s✓%s %s\n' "$g" "$z" "$1"; }
bad(){   fail=$((fail+1)); printf '  %s✗%s %s\n' "$r" "$z" "$*"; }
skipt(){ skip=$((skip+1)); printf '  %s—%s %s\n' "$y" "$z" "$*"; }
have(){  if [ -e "$1" ]; then ok "$2"; else bad "$2 — missing: $1"; fi; }
gone(){  if [ ! -e "$1" ]; then ok "$2"; else bad "$2 — still exists: $1"; fi; }
eq(){    if [ "$1" = "$2" ]; then ok "$3"; else bad "$3 — got [$1] want [$2]"; fi; }
hasstr(){ case "$1" in *"$2"*) ok "$3";; *) bad "$3 — [$2] not in output";; esac; }

# ---- fixtures / runners ---------------------------------------------------
mkenv(){ e="$(mktemp -d)"; mkdir -p "$e/data/lf" "$e/jobs" "$e/cache" "$e/work" "$e/src"; printf '%s' "$e"; }
setbuf(){ printf '%s\n' "$@" > "$E/data/lf/files"; }              # setbuf <mode> <path...>
runjob(){ ( cd "$1" && shift && XDG_DATA_HOME="$E/data" TMPDIR="$E/jobs" XDG_CACHE_HOME="$E/cache" "$JOB" "$@" ); }
runscope(){ XDG_CACHE_HOME="$E/cache" "$SCOPE" "$@"; }
runtabs(){ TMPDIR="$E/jobs" "$TABS" "$@"; }
await(){ p="$1"; for _ in $(seq 1 60); do [ -e "$p" ] && return 0; sleep 0.2; done; return 1; }
now(){ perl -MTime::HiRes -e 'printf "%.3f", Time::HiRes::time()' 2>/dev/null || date +%s; }
mag=0; command -v magick >/dev/null 2>&1 && mag=1

# ---- run one named test (a function), timed, honouring the filter ---------
test_case(){   # test_case <name> <function>
  case "$1" in *"$FILTER"*) ;; *) return 0;; esac
  printf '\n%s• %s%s\n' "$b" "$1" "$z"
  __t0="$(now)"
  "$2"
  printf '  %s%ss%s\n' "$d" "$(awk -v a="$(now)" -v s="$__t0" 'BEGIN{printf "%.3f", a-s}')" "$z"
}

# ---- go -------------------------------------------------------------------
T0="$(now)"
for grp in paste extract archive scope tabs cleaner; do . "$ROOT/tests/$grp.sh"; done

printf '\n%s%d passed%s' "$g" "$pass" "$z"
[ "$fail" -gt 0 ] && printf ', %s%d failed%s' "$r" "$fail" "$z" || printf ', %d failed' "$fail"
[ "$skip" -gt 0 ] && printf ', %d skipped' "$skip"
printf '  %sin %ss%s\n' "$d" "$(awk -v a="$(now)" -v s="$T0" 'BEGIN{printf "%.2f", a-s}')" "$z"
[ "$fail" -eq 0 ]
