#!/usr/local/bin/shit --bash-compatible
# cleaner.sh runs cleanly.

t_cleaner(){
  "$CLEAN" prev >/dev/null 2>&1; eq "$?" 0 "cleaner runs and exits 0"
}
test_case cleaner t_cleaner
