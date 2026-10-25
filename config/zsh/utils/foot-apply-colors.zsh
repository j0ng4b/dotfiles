# Apply foot colors when available
#
# `foot --server` reads its config (colors.ini) only once, at startup, so any
# window opened afterwards starts with the colors from that moment, even if the
# theme was changed since. color-reloader repaints the terminals that are
# already open, but a new one has nothing to repaint it. It keeps the
# escape sequences of the current theme in this file, so replaying them here
# makes every new shell start with the right colors.
foot_seqs="${XDG_CACHE_HOME:-$HOME/.cache}/scripter/color-reloader/foot_seqs"
[ -f "$foot_seqs" ] && command cat "$foot_seqs"
