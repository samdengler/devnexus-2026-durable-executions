#!/usr/bin/env bash
set -euo pipefail

SESSION="devnexus"

tmux send-keys -t "$SESSION:1.0" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:1.1" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:0.0" C-c 2>/dev/null || true
tmux send-keys -t "$SESSION:0.1" C-c 2>/dev/null || true
sleep 2
tmux kill-session -t "$SESSION" 2>/dev/null || true
lsof -ti :8080 | xargs kill 2>/dev/null || true
lsof -ti :9080 | xargs kill 2>/dev/null || true
lsof -ti :9070 | xargs kill 2>/dev/null || true
