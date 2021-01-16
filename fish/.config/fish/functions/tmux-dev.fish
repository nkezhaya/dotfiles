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
    new-session -c ~/Code/BasicSpace/basic_space -n basic_space -s bs \; \
    split-window -h \; \
    select-pane -t 1 \; \
    split-window -v \; \
    new-window -n basic_space \; \
    new-window -n basic_space \; \
    new-window -n basic_space \; \
    new-window -n basic_space \; \
    new-window -n Basic\ Space -c ~/Code/BasicSpace/Basic\ Space \; \
    new-window -n basic_space \; \
    select-window -t 0 \;
end
