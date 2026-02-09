#!/bin/bash

set -e

FAIL_FLAG="FAIL_DEMO"

case "$1" in
  break)
    echo "[BREAK] Creating FAIL_DEMO flag - service will fail"
    touch "$FAIL_FLAG"
    ;;
  fix)
    echo "[FIX] Removing FAIL_DEMO flag - service will succeed"
    rm -f "$FAIL_FLAG"
    ;;
  invoke)
    NAME="${2:-Alice}"
    echo "[INVOKE] Calling Greeter service with name: $NAME"
    curl --max-time 5 -X POST http://localhost:8080/Greeter/greet \
      -H "Content-Type: application/json" \
      -d "{\"name\": \"$NAME\"}" \
      -w "\n" || echo "[INVOKE] Request timed out or failed - check Restate console"
    ;;
  status)
    if [ -f "$FAIL_FLAG" ]; then
      echo "[STATUS] FAIL_DEMO flag exists - service will fail"
    else
      echo "[STATUS] FAIL_DEMO flag removed - service will succeed"
    fi
    ;;
  *)
    echo "Durable Execution Demo Control"
    echo ""
    echo "Usage: $0 {break|fix|invoke [name]|status}"
    echo ""
    echo "  break        - Create FAIL_DEMO flag (service will fail)"
    echo "  fix          - Remove FAIL_DEMO flag (service will succeed)"
    echo "  invoke [name] - Call the Greeter service (default: Alice)"
    echo "  status       - Check if FAIL_DEMO flag exists"
    echo ""
    echo "Demo Flow:"
    echo "  1. ./demo-control.sh break"
    echo "  2. ./demo-control.sh invoke   (will fail)"
    echo "  3. Open http://localhost:9070 (check failed invocation)"
    echo "  4. ./demo-control.sh fix"
    echo "  5. Resume invocation in console (watch replay!)"
    exit 1
    ;;
esac
