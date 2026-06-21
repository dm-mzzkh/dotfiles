#!/usr/local/bin/shit --bash-compatible
# paste tests (sourced by ../run.sh) — job.sh paste: copy/move × rename/merge.

t_paste_copy_rename(){
  E="$(mkenv)"
  mkdir -p "$E/work/proj" "$E/src/proj"; echo OLD >"$E/work/proj/a.txt"
  echo NEW >"$E/src/proj/a.txt"; echo b >"$E/src/proj/b.txt"
  setbuf copy "$E/src/proj"; runjob "$E/work" paste rename; await "$E/work/proj_1/a.txt"
  have "$E/work/proj_1/a.txt" "collision -> proj_1/"
  eq "$(cat "$E/work/proj/a.txt")" OLD "existing proj left untouched"
  have "$E/work/proj_1/b.txt"  "proj_1 has full copy"
  rm -rf "$E"
}
test_case paste-copy-rename t_paste_copy_rename

t_paste_copy_merge(){
  E="$(mkenv)"
  mkdir -p "$E/work/p/sub" "$E/src/p/sub"
  echo OLD >"$E/work/p/shared.txt"; echo keep >"$E/work/p/sub/k.txt"
  echo NEW >"$E/src/p/shared.txt";  echo n >"$E/src/p/sub/n.txt"
  setbuf copy "$E/src/p"; runjob "$E/work" paste merge; await "$E/work/p/sub/n.txt"
  eq "$(cat "$E/work/p/shared.txt")" NEW "merge: source wins on clashing file"
  have "$E/work/p/sub/k.txt" "merge: keeps existing nested file"
  have "$E/work/p/sub/n.txt" "merge: adds new nested file"
  rm -rf "$E"
}
test_case paste-copy-merge t_paste_copy_merge

t_paste_move_rename(){
  E="$(mkenv)"
  echo old >"$E/work/f.txt"; echo s >"$E/src/f.txt"
  setbuf move "$E/src/f.txt"; runjob "$E/work" paste rename; await "$E/work/f_1.txt"
  have "$E/work/f_1.txt" "move collision -> f_1.txt"
  gone "$E/src/f.txt"     "move removes the source"
  rm -rf "$E"
}
test_case paste-move-rename t_paste_move_rename

t_paste_move_merge(){
  E="$(mkenv)"
  mkdir -p "$E/work/d" "$E/src/d"; echo keep >"$E/work/d/k.txt"; echo n >"$E/src/d/n.txt"
  setbuf move "$E/src/d"; runjob "$E/work" paste merge; await "$E/work/d/n.txt"
  have "$E/work/d/k.txt" "move-merge keeps existing file"
  have "$E/work/d/n.txt" "move-merge adds moved file"
  gone "$E/src/d"        "move-merge removes the source dir"
  rm -rf "$E"
}
test_case paste-move-merge t_paste_move_merge
