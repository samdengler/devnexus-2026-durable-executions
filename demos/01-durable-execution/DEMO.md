# Durable Execution Demo - Replay Showcase

This demo shows how Restate's durable execution handles failures and replay.

📖 **See [JOURNAL-PROTOCOL.md](JOURNAL-PROTOCOL.md) for detailed sequence diagrams showing how the SDK and Runtime communicate.**

## Demo Flow

### 1. Setup - Make it fail first
```bash
# Create the FAIL_DEMO flag file to simulate a service outage
touch FAIL_DEMO
```

### 2. Start the service
```bash
npm run app
```

### 3. Invoke the service (it will fail)
```bash
# Using the helper script (recommended)
./demo-control.sh invoke          # defaults to "Alice"
./demo-control.sh invoke Bob      # or use a custom name

# Or manually with curl
curl --max-time 5 -X POST http://localhost:8080/Greeter/greet \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice"}'
```

**Expected**:
- The request will timeout after 5 seconds
- Restate keeps the invocation in a suspended/retry state
- The command returns so you can continue with the demo

### 4. Check the Restate console
Open http://localhost:9070 and you'll see:
- The invocation in a **failed/suspended** state
- The journal showing which steps completed before the failure
- The random UUID was generated and persisted (won't change on replay!)
- The first `ctx.run("Notification")` failed

### 5. Fix the issue
```bash
# Remove the flag file to "fix" the service
rm FAIL_DEMO
```

### 6. Resume the invocation
In the Restate console:
- Find the failed invocation
- Click **"Resume"** or **"Retry"**

**Watch the magic happen**:
- The same UUID is used (from replay, not regenerated)
- Steps that succeeded before are **not re-executed** (replayed from journal)
- Execution continues from the failure point
- The invocation completes successfully

## Key Observations

### What Gets Replayed vs What Gets Journaled

**Check the console output and `replay-log.txt` file:**

1. **NON-DURABLE** (replayed every time):
   - `logNonDurableStep()` calls execute AGAIN on resume
   - Different timestamps in console for the same logical step
   - `replay-log.txt` will have duplicate entries with new timestamps
   - This shows code OUTSIDE `ctx.run()` is **not idempotent**

2. **DURABLE** (journaled, executed once):
   - `ctx.rand.uuidv4()` returns the **same UUID** on resume
   - `sendNotification()` inside `ctx.run()` only executes once
   - Console shows "Replaying from journal" for completed steps
   - Side effects in `ctx.run()` are **idempotent**

### Compare the timestamps:
```bash
# Watch the console during first invocation - note timestamps
# Then resume after removing FAIL_DEMO
# The NON-DURABLE logs will have NEW timestamps
# The UUID will be IDENTICAL (from journal)

# Also check the file:
cat replay-log.txt
# You'll see duplicate entries with different timestamps!
```

3. **Deterministic Replay**: The `ctx.rand.uuidv4()` returns the same value
4. **Partial Progress**: Steps before the failure are not re-executed
5. **Zero Code Changes**: The same code handles both failure and resume
6. **Automatic Recovery**: Restate manages all the complexity

## Cleanup
```bash
# Make sure flag is removed for next demo
rm -f FAIL_DEMO
```
