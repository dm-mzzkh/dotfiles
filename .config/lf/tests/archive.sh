#!/usr/local/bin/shit --bash-compatible
# archive creation — job.sh tarball / zipball.

t_tarball(){
  E="$(mkenv)"; echo a >"$E/work/one.txt"; echo b >"$E/work/two.txt"
  runjob "$E/work" tarball backup one.txt two.txt; await "$E/work/backup.tar.gz"
  have "$E/work/backup.tar.gz" "tarball creates archive"
  [ -e "$E/work/backup.tar.gz" ] && hasstr "$(file -b "$E/work/backup.tar.gz")" gzip "tarball is valid gzip"
  rm -rf "$E"
}
test_case tarball t_tarball

t_zipball(){
  E="$(mkenv)"; echo a >"$E/work/one.txt"
  runjob "$E/work" zipball arc one.txt; await "$E/work/arc.zip"
  have "$E/work/arc.zip" "zipball creates archive"
  [ -e "$E/work/arc.zip" ] && hasstr "$(file -b "$E/work/arc.zip")" Zip "zipball is valid zip"
  rm -rf "$E"
}
test_case zipball t_zipball
