#!/usr/local/bin/shit --bash-compatible
# tabs.sh state management — sync / new / close.

t_tabs(){
  E="$(mkenv)"; tid=tst
  runtabs sync "$tid" /tmp >/dev/null 2>&1
  eq "$(cat "$E/jobs/lf-tabs/tabs.$tid" 2>/dev/null)" /tmp "sync records the current dir"
  runtabs new "$tid" /usr >/dev/null 2>&1
  eq "$(grep -c '' "$E/jobs/lf-tabs/tabs.$tid" 2>/dev/null)" 2 "new opens a second tab"
  runtabs close "$tid" /usr >/dev/null 2>&1
  eq "$(grep -c '' "$E/jobs/lf-tabs/tabs.$tid" 2>/dev/null)" 1 "close removes a tab"
  rm -rf "$E"
}
test_case tabs t_tabs
