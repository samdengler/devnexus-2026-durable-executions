#!/usr/bin/env bash
set -euo pipefail

echo "Starting Restate server..."

# Try Docker first, fall back to local binary
if command -v docker &>/dev/null; then
  docker run --name restate_dev --rm \
    -p 8080:8080 \
    -p 9070:9070 \
    -p 9071:9071 \
    docker.restate.dev/restatedev/restate:latest
elif command -v restate-server &>/dev/null; then
  restate-server
else
  echo "Error: Neither docker nor restate-server found."
  echo "Install via: brew install restatedev/tap/restate-server"
  echo "         or: npm install -g @restatedev/restate-server@latest"
  exit 1
fi
