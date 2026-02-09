#!/usr/bin/env bash
set -euo pipefail

SESSION="devnexus"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Kill existing session if present
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Create session with 3 panes:
#   ┌──────────┬──────────┐
#   │ restate  │ service  │
#   │ server   │  logs    │
#   ├──────────┴──────────┤
#   │      commands       │
#   └─────────────────────┘

tmux new-session -d -s "$SESSION" -x 200 -y 50

# Split top/bottom: 70% top, 30% bottom
tmux split-window -v -p 30 -t "$SESSION:0.0"

# Split top pane left/right: 55% left (server), 45% right (service)
tmux split-window -h -p 45 -t "$SESSION:0.0"

# Top-left (pane 0): Restate server
tmux send-keys -t "$SESSION:0.0" "cd $ROOT && restate up --retain" Enter

# Top-right (pane 1): Service logs
tmux send-keys -t "$SESSION:0.1" "cd $ROOT/demos/01-durable-execution && npm run dev" Enter

# Bottom (pane 2): Command pane
tmux send-keys -t "$SESSION:0.2" "cd $ROOT" Enter

# Focus the command pane (bottom)
tmux select-pane -t "$SESSION:0.2"

# Attach
tmux attach -t "$SESSION"
