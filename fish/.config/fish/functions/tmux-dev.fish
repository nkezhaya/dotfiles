function tmux-dev
  tmux new-session -c ~/Code/StatWindow/stat_window -n stat_window -s sw \; \
    split-window -h \; \
    select-pane -t 1 \; \
    split-window -v \; \
    new-window -n stat_window \; \
    new-window -n stat_window \; \
    new-window -n stat_window \; \
    new-window -n stat_window \; \
    new-window -n stat_window \; \
    new-window -n stat_window \; \
    select-window -t 0 \; \
    new-session -c ~/Code/loki -n elc -s elc \; \
    split-window -v \; \
    new-window -n elc \; \
    new-window -n elc \; \
    new-window -n elc \; \
    new-window -n elc \; \
    new-window -n elc \; \
    select-window -t 0 \;
end
