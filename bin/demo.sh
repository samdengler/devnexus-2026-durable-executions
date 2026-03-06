#!/usr/bin/env bash
set -euo pipefail

SESSION="devnexus"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Gracefully stop existing session if present
tmux send-keys -t "$SESSION:1.0" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:1.1" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:0.0" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:0.1" C-c 2>/dev/null || true
sleep 2
tmux kill-session -t "$SESSION" 2>/dev/null || true
# Kill any leftover processes on restate ports
lsof -ti :8080 | xargs kill 2>/dev/null || true
lsof -ti :9080 | xargs kill 2>/dev/null || true
lsof -ti :9070 | xargs kill 2>/dev/null || true

# Layout:
#   Window 0 (Demo):        Window 1 (Services):
#   ┌────────────────────┐  ┌────────────────────┐
#   │       code         │  │   restate server    │
#   ├────────────────────┤  ├────────────────────┤
#   │     commands       │  │   service logs      │
#   └────────────────────┘  └────────────────────┘

tmux new-session -d -s "$SESSION" -x 106 -y 50

# Window 0: Demo - code (top) + commands (bottom)
tmux split-window -v -p 33 -t "$SESSION:0.0"

# Top (pane 0): Code viewer
tmux send-keys -t "$SESSION:0.0" "export BAT_OPTS='--terminal-width=106' && cd $ROOT/demos/01-durable-execution && bat src/app.ts" Enter

# Bottom (pane 1): Command pane (short prompt for demo readability)
tmux send-keys -t "$SESSION:0.1" "export PS1='%% ' && cd $ROOT/demos/01-durable-execution && clear" Enter
tmux send-keys -t "$SESSION:0.1" "restate deployments register http://localhost:9080"

# Window 1: Services (hidden) - restate server + service
tmux new-window -t "$SESSION:1" -n "Services"
tmux split-window -v -p 50 -t "$SESSION:1.0"

# Top (pane 0): Restate server
tmux send-keys -t "$SESSION:1.0" "cd $ROOT/demos/01-durable-execution && restate-server" Enter

# Bottom (pane 1): Service logs
tmux send-keys -t "$SESSION:1.1" "cd $ROOT/demos/01-durable-execution && npm run dev" Enter

# Label panes
tmux select-pane -t "$SESSION:0.0" -T "Code"
tmux select-pane -t "$SESSION:0.1" -T "Commands"
tmux select-pane -t "$SESSION:1.0" -T "Restate Server"
tmux select-pane -t "$SESSION:1.1" -T "Service"

# Switch back to demo window
tmux select-window -t "$SESSION:0"
tmux set-option -t "$SESSION" pane-border-status top
tmux set-option -t "$SESSION" pane-border-format "#{?pane_active,#[fg=red#,bold],#[fg=yellow#,bold]}  #{pane_index}: #{pane_title}  #[default]"

# Keybindings: Ctrl+b <num> to select pane, Ctrl+b X to kill session
tmux bind-key -T prefix 0 select-pane -t 0
tmux bind-key -T prefix 1 select-pane -t 1
tmux bind-key -T prefix 2 select-pane -t 2
tmux bind-key -T prefix 3 select-pane -t 3
tmux bind-key -T prefix X confirm-before -p "kill-session? (y/n)" \
  "send-keys -t ${SESSION}:1.0 C-c ; send-keys -t ${SESSION}:1.1 C-c ; run-shell 'sleep 1' ; kill-session"
tmux bind-key -T prefix x confirm-before -p "kill-session? (y/n)" \
  "send-keys -t ${SESSION}:1.0 C-c ; send-keys -t ${SESSION}:1.1 C-c ; run-shell 'sleep 1' ; kill-session"
tmux set-option -g display-panes-time 5000
tmux set-option -t "$SESSION" -g mouse on
tmux bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe "pbcopy"
tmux bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe "pbcopy"
tmux set-option -t "$SESSION" message-style "fg=yellow,bg=#1e293b,bold"
tmux set-option -t "$SESSION" status-style "fg=yellow,bg=#1e293b"

# Open Restate UI in cmux browser (falls back silently if not in cmux)
sleep 1
command -v cmux &>/dev/null && cmux browser open http://localhost:9070 2>/dev/null || true

# Focus the command pane
tmux select-pane -t "$SESSION:0.1"

# Attach
tmux attach -t "$SESSION"
