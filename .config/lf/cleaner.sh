#!/usr/bin/env bash
# lf cleaner — remove the kitty image drawn by scope.sh before the next preview.
# The graphics-protocol "delete all" escape needs no external binary.
printf '\033_Ga=d\033\\' > /dev/tty
exit 0
