#!/usr/local/bin/shit --bash-compatible
# Background-job runner + popup viewer for lf.
#
#   job.sh paste|extract|compress|tarball|zipball ...   launch detached job(s)
#   job.sh view                                         live render (run in popup)
#   job.sh clean                                        drop finished job files
#
# Heavy operations are launched detached so lf never blocks. Each job streams its
# progress to a file under $DIR; `gj` in lf opens a tmux popup running `view`,
# which renders ALL active jobs together — several progress bars at once.
# Kept POSIX-ish / bash 3.2 friendly (macOS system bash).

set -u
DIR="${TMPDIR:-/tmp}/lf-jobs"
mkdir -p "$DIR"
LFID="${LF_ID:-}"

# ---- launch ---------------------------------------------------------------

_spawn() {                                   # _spawn <label> <command...>
    local label="$1"; shift
    local id meta out
    id="$(date +%H%M%S)-$$-${RANDOM:-0}"
    meta="$DIR/$id.meta"; out="$DIR/$id.out"
    : > "$out"
    printf 'label=%s\nstatus=running\nstart=%s\n' "$label" "$(date +%s)" > "$meta"
    (
        trap '' HUP INT                      # outlive lf / terminal close
        "$@" >> "$out" 2>&1
        rc=$?
        st=done; [ "$rc" -ne 0 ] && st=failed
        printf 'label=%s\nstatus=%s\nrc=%s\nend=%s\n' "$label" "$st" "$rc" "$(date +%s)" > "$meta"
        [ -n "$LFID" ] && lf -remote "send $LFID reload" 2>/dev/null
        [ -z "${LF_NO_NOTIFY:-}" ] && command -v osascript >/dev/null 2>&1 &&
            osascript -e "display notification \"$label\" with title \"lf job: $st\"" >/dev/null 2>&1
        true
    ) </dev/null >/dev/null 2>&1 &
}

# free, non-colliding name in cwd: dirs -> name_N, files -> name_N.ext
_freename() {
    local src="$1" base stem ext n
    base="$(basename "$src")"
    [ ! -e "./$base" ] && { printf './%s' "$base"; return; }
    if [ -d "$src" ]; then stem="$base"; ext=""
    else case "$base" in ?*.?*) stem="${base%.*}"; ext=".${base##*.}";; *) stem="$base"; ext="";; esac
    fi
    n=1; while [ -e "./${stem}_${n}${ext}" ]; do n=$(( n + 1 )); done
    printf './%s_%s%s' "$stem" "$n" "$ext"
}

# free, non-colliding full path (path, path_1, path_2, ...)
_freefile() {
    local p="$1" n=1
    [ ! -e "$p" ] && { printf '%s' "$p"; return; }
    while [ -e "${p}_${n}" ]; do n=$(( n + 1 )); done
    printf '%s_%s' "$p" "$n"
}

# copy one src into cwd.
#   policy=rename : never touch an existing entry; new copy becomes name_N
#   policy=merge  : merge dirs recursively (source wins on file collisions)
_copy_one() {
    local policy="$1" src="$2" base t cs
    base="$(basename "$src")"
    if [ "$policy" = merge ]; then
        cs=""; [ -e "./$base" ] && cs="--checksum"   # decide by content so source wins on clashes
        if [ -d "$src" ]; then mkdir -p "./$base"; rsync -a $cs --progress "$src/" "./$base/"
        else rsync -a $cs --progress "$src" "./$base"; fi
    else
        t="$(_freename "$src")"
        if [ -d "$src" ]; then rsync -a --progress "$src/" "$t/"
        else rsync -a --progress "$src" "$t"; fi
    fi
}

# move one src into cwd, same policies (merge = copy-merge then drop source).
_move_one() {
    local policy="$1" src="$2" base t
    base="$(basename "$src")"
    if [ -e "./$base" ]; then
        if [ "$policy" = merge ]; then _copy_one merge "$src" && rm -rf -- "$src"
        else t="$(_freename "$src")"; mv -- "$src" "$t"; fi
    else
        mv -- "$src" "./$base"
    fi
}

_do_paste() {                                # _do_paste <policy> <mode> <src...>
    local policy="$1" mode="$2" src; shift 2
    for src in "$@"; do
        if [ "$mode" = copy ]; then _copy_one "$policy" "$src"; else _move_one "$policy" "$src"; fi
    done
}
_do_compress() { compress_video "$1" ; }
_do_tar()      { local n="$1"; shift; mkdir -p "$n" && cp -r "$@" "$n" && tar czvf "$n.tar.gz" "$n" && rm -rf "$n"; }
_do_zip()      { local n="$1"; shift; mkdir -p "$n" && cp -r "$@" "$n" && zip -r "$n.zip" "$n" && rm -rf "$n"; }
_do_extract()  {
    local f="$1" base dir n o
    case "$f" in
        *.tar|*.tar.*|*.tbz|*.tbz2|*.tgz|*.txz|*.tzst|*.zip|*.jar|*.rar|*.7z)
            base="$(basename "$f")"
            dir="${base%.tar.*}"; [ "$dir" = "$base" ] && dir="${base%.*}"
            # unique subdir so two archives (or a re-extract) never collide
            if [ -e "$dir" ]; then n=1; while [ -e "${dir}_${n}" ]; do n=$(( n + 1 )); done; dir="${dir}_${n}"; fi
            mkdir -p -- "$dir"
            case "$f" in
                *.tar|*.tar.*|*.tbz|*.tbz2|*.tgz|*.txz|*.tzst) tar xvf "$f" -C "$dir";;
                *.zip|*.jar) unzip -o -d "$dir" "$f";;
                *.rar)       unrar x -y "$f" "$dir"/;;
                *.7z)        7z x -y -o"$dir" "$f";;
            esac ;;
        *.gz)  o="$(_freefile "${f%.gz}")";  gunzip  -c "$f" > "$o" ;;
        *.bz2) o="$(_freefile "${f%.bz2}")"; bunzip2 -c "$f" > "$o" ;;
        *.xz)  o="$(_freefile "${f%.xz}")";  xz  -dc "$f" > "$o" ;;
        *.zst) o="$(_freefile "${f%.zst}")"; zstd -dc "$f" > "$o" ;;
        *) printf 'no extractor for %s\n' "$f"; return 1;;
    esac
}

# ---- render ---------------------------------------------------------------

_bar() {                                     # _bar <pct> -> ████░░░░
    local p="${1:-0}" w=18 i f s=""
    case "$p" in (*[!0-9]*|'') p=0;; esac
    [ "$p" -gt 100 ] && p=100
    f=$(( p * w / 100 ))
    for (( i=0; i<w; i++ )); do
        if [ "$i" -lt "$f" ]; then s="${s}█"; else s="${s}░"; fi
    done
    printf '%s' "$s"
}

_view() {
    local spinner='|/-\' tick=0 key
    local meta id out label status rc start end now last pct ela any running
    command -v tput >/dev/null 2>&1 && tput civis 2>/dev/null
    trap 'command -v tput >/dev/null 2>&1 && tput cnorm 2>/dev/null' EXIT
    while :; do
        now="$(date +%s)"
        printf '\033[H\033[2J  lf · background jobs\n\n'
        any=0; running=0
        for meta in "$DIR"/*.meta; do
            [ -e "$meta" ] || continue
            label="$(sed -n 's/^label=//p'  "$meta")"
            status="$(sed -n 's/^status=//p' "$meta")"
            rc="$(sed -n 's/^rc=//p'      "$meta")"
            start="$(sed -n 's/^start=//p'  "$meta")"
            end="$(sed -n 's/^end=//p'    "$meta")"
            id="$(basename "$meta" .meta)"; out="$DIR/$id.out"
            any=1
            case "$status" in
                running)
                    running=$(( running + 1 ))
                    last="$(tail -c 8192 "$out" 2>/dev/null | tr '\r' '\n' | grep -v '^[[:space:]]*$' | tail -1)"
                    pct="$(printf '%s' "$last" | grep -oE '[0-9]+%' | tail -1 | tr -d '%')"
                    ela=$(( now - ${start:-now} ))
                    if [ -n "$pct" ]; then
                        printf '  ▸ %-22.22s %s %3s%%  %ss\n' "$label" "$(_bar "$pct")" "$pct" "$ela"
                    else
                        printf '  %s %-22.22s  %.42s\n' "${spinner:tick%4:1}" "$label" "${last:-…}"
                    fi ;;
                done)
                    printf '  ✓ %-22.22s  done\n' "$label"
                    [ -n "$end" ] && [ $(( now - end )) -gt 8 ] && rm -f "$meta" "$out" ;;
                failed)
                    printf '  ✗ %-22.22s  failed (rc=%s)\n' "$label" "${rc:-?}"
                    [ -n "$end" ] && [ $(( now - end )) -gt 20 ] && rm -f "$meta" "$out" ;;
            esac
        done
        [ "$any" = 0 ] && printf '  (no active jobs)\n'
        printf '\n  [q] close    running: %s\n' "$running"
        tick=$(( tick + 1 ))
        key=""; IFS= read -rsn1 -t 1 key 2>/dev/null   # (don't rely on read's rc;
        [ "${key:-}" = q ] && break                    #  shit returns 1 even on a read)
    done
}

# ---- dispatch -------------------------------------------------------------

cmd="${1:-}"; [ $# -gt 0 ] && shift
case "$cmd" in
    paste)
        policy="${1:-rename}"                # rename (p) | merge (P)
        buf="${XDG_DATA_HOME:-$HOME/.local/share}/lf/files"
        [ -s "$buf" ] || exit 0
        mode="$(sed -n 1p "$buf")"
        files=()
        while IFS= read -r l; do [ -n "$l" ] && files+=("$l"); done < <(sed 1d "$buf")
        [ "${#files[@]}" -eq 0 ] && exit 0
        _spawn "${mode} ${policy} ${#files[@]} item(s)" _do_paste "$policy" "$mode" "${files[@]}" ;;
    extract)
        for f in "$@"; do _spawn "extract $(basename "$f")" _do_extract "$f"; done ;;
    compress)
        for f in "$@"; do _spawn "compress $(basename "$f")" _do_compress "$f"; done ;;
    tarball) n="$1"; shift; _spawn "tar $n" _do_tar "$n" "$@" ;;
    zipball) n="$1"; shift; _spawn "zip $n" _do_zip "$n" "$@" ;;
    view)    _view ;;
    clean)
        for meta in "$DIR"/*.meta; do
            [ -e "$meta" ] || continue
            status="$(sed -n 's/^status=//p' "$meta")"
            [ "$status" != running ] && rm -f "$meta" "${meta%.meta}.out"
        done ;;
    *) printf 'usage: job.sh paste|extract|compress|tarball|zipball|view|clean\n' >&2; exit 2 ;;
esac
