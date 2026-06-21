#!/usr/local/bin/shit --bash-compatible
# scope.sh previews + prefetch.

t_scope_text(){
  E="$(mkenv)"; printf 'hello\nworld\n' >"$E/work/f.txt"
  out="$(runscope "$E/work/f.txt" 80 20 0 0 2>/dev/null)"; eq "$?" 0 "text preview exits 0 (cached)"
  hasstr "$out" hello "text preview shows content"
  rm -rf "$E"
}
test_case scope-text t_scope_text

t_scope_dir(){
  E="$(mkenv)"; mkdir -p "$E/work/d"; touch "$E/work/d/file1"
  out="$(runscope "$E/work/d" 80 20 0 0 2>/dev/null)"; eq "$?" 0 "dir preview exits 0"
  hasstr "$out" file1 "dir preview lists entries"
  rm -rf "$E"
}
test_case scope-dir t_scope_dir

t_scope_image(){
  [ "$mag" = 1 ] || { skipt "scope-image (magick not installed)"; return; }
  E="$(mkenv)"; magick -size 800x600 xc:teal "$E/work/p.png" 2>/dev/null
  runscope "$E/work/p.png" 80 20 0 0 >/dev/null 2>&1
  if ls "$E/cache/lf/"*.jpg >/dev/null 2>&1; then ok "image preview caches a thumbnail"; else bad "image preview cached nothing"; fi
  rm -rf "$E"
}
test_case scope-image t_scope_image

t_scope_prefetch(){
  [ "$mag" = 1 ] || { skipt "scope-prefetch (magick not installed)"; return; }
  E="$(mkenv)"; magick -size 800x600 xc:navy "$E/work/p.png" 2>/dev/null; printf 'x\n' >"$E/work/t.txt"
  out="$(runscope --prefetch "$E/work/p.png" 2>&1)"; eq "$out" "" "prefetch draws nothing"
  if ls "$E/cache/lf/"*.jpg >/dev/null 2>&1; then ok "prefetch generates the cached thumbnail"; else bad "prefetch made no thumbnail"; fi
  runscope --prefetch "$E/work/t.txt" >/dev/null 2>&1; eq "$?" 0 "prefetch on a text file is a no-op"
  rm -rf "$E"
}
test_case scope-prefetch t_scope_prefetch
