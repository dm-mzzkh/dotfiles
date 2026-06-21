#!/usr/local/bin/shit --bash-compatible
# extract tests — archives into a unique subdir, single-file decompressors.

t_extract_archives(){
  E="$(mkenv)"
  ( cd "$E/work" && mkdir pkg && echo hi >pkg/a.txt && tar czf arc.tar.gz pkg && zip -qr arc.zip pkg && rm -rf pkg )
  runjob "$E/work" extract "$E/work/arc.tar.gz" "$E/work/arc.zip"
  await "$E/work/arc" && await "$E/work/arc_1"
  have "$E/work/arc"   "tar.gz extracts into arc/"
  have "$E/work/arc_1" "same-stem zip -> arc_1/ (no clash)"
  rm -rf "$E"
}
test_case extract-archives t_extract_archives

t_extract_single(){
  E="$(mkenv)"
  ( cd "$E/work" && echo payload >data && gzip -k data && bzip2 -k data && rm -f data )
  runjob "$E/work" extract "$E/work/data.gz";  await "$E/work/data"
  runjob "$E/work" extract "$E/work/data.bz2"; await "$E/work/data_1"
  have "$E/work/data"    ".gz decompresses to data"
  have "$E/work/data_1"  ".bz2 collision -> data_1"
  have "$E/work/data.gz" "original archive kept"
  rm -rf "$E"
}
test_case extract-single t_extract_single
