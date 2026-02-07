#!/usr/bin/env bash
set -euo pipefail

echo "Registering demo services with Restate..."

# Demo 01: Durable Execution (port 9080)
restate deployments register http://localhost:9080 --yes
echo "Registered: 01-durable-execution"

echo "All demos registered."
