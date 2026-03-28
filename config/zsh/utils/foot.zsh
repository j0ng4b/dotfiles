# Apply foot colors when available
foot_seqs="${XDG_CACHE_HOME:-$HOME/.cache}/scripter/color-reloader/foot_seqs"
[ -f "$foot_seqs" ] && command cat "$foot_seqs"
