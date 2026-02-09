# Restate Journal Protocol - Sequence Diagrams

## Initial Invocation (First Execution)

```mermaid
sequenceDiagram
    participant Client
    participant Server as Restate Server<br/>(Ingress + Storage)
    participant Journal as Journal<br/>(SDK)
    participant Handler as Handler Code

    Client->>Server: POST /Greeter/greet<br/>{"name": "Alice"}
    Note over Server: Create invocation,<br/>assign ID

    Server->>Journal: StartMessage<br/>(empty journal)
    activate Journal

    Journal->>Handler: Execute handler(ctx, {name})
    activate Handler

    Note over Handler: logNonDurableStep("Handler started")<br/>(NOT journaled, just executes)

    Handler->>Journal: ctx.rand.uuidv4()
    Journal->>Journal: Check journal: empty
    Journal->>Server: GetRandomSeedEntry
    Server->>Server: 💾 Persist journal entry
    Server-->>Journal: CompletionMessage (seed)
    Journal->>Journal: Add to journal
    Journal-->>Handler: return uuid-1234

    Note over Handler: logNonDurableStep("About to send...")<br/>(NOT journaled, just executes)

    Handler->>Journal: ctx.run("Notification", fn)
    Journal->>Journal: Check journal: no entry
    Journal->>Server: RunEntry (running)
    Server->>Server: 💾 Persist journal entry
    Handler->>Handler: Execute sendNotification()
    Note over Handler: ❌ throws Error (FAIL_DEMO exists)
    Handler-->>Journal: Error thrown
    Journal->>Server: RunEntry (failed)
    Server->>Server: 💾 Update entry status

    Server-->>Journal: Suspend signal
    Journal-->>Server: SuspensionMessage
    deactivate Handler
    deactivate Journal
    Server-->>Client: ⏸️ 504 Request suspended

    Note over Server: Journal persisted:<br/>1. GetRandomSeed ✅ COMPLETED<br/>2. RunEntry "Notification" ❌ FAILED
```

## Resume After Fix (Replay Execution)

```mermaid
sequenceDiagram
    participant User
    participant Server as Restate Server<br/>(Ingress + Storage)
    participant Journal as Journal<br/>(SDK)
    participant Handler as Handler Code

    User->>Server: Click "Resume" in console
    Note over Server: Load persisted journal:<br/>GetRandomSeed ✅<br/>RunEntry (failed) ❌

    Server->>Journal: StartMessage (includes journal)
    Server->>Journal: Replay: GetRandomSeedEntry ✅<br/>(seed for uuid-1234)
    activate Journal
    Note over Journal: Journal loaded with<br/>1 completed entry

    Journal->>Handler: Execute handler(ctx, {name})
    activate Handler

    Note over Handler: logNonDurableStep("Handler started")<br/>⚠️ RUNS AGAIN with NEW timestamp

    Handler->>Journal: ctx.rand.uuidv4()
    Journal->>Journal: ✅ Check journal: entry exists!
    Journal-->>Handler: Return from journal: uuid-1234

    Note over Handler: logNonDurableStep("About to send...")<br/>⚠️ RUNS AGAIN with NEW timestamp

    Handler->>Journal: ctx.run("Notification", fn)
    Journal->>Journal: ❌ Check journal: failed entry,<br/>must re-execute
    Journal->>Server: RunEntry (running)
    Server->>Server: 💾 Persist new attempt
    Handler->>Handler: Execute sendNotification()
    Note over Handler: FAIL_DEMO removed ✅
    Handler-->>Journal: Success!
    Journal->>Server: RunEntry (completed)
    Server->>Server: 💾 Update entry status
    Server-->>Journal: CompletionMessage
    Journal->>Journal: Update journal

    Handler->>Journal: ctx.sleep(1s)
    Journal->>Server: SleepEntry (1000ms)
    Server->>Server: 💾 Persist sleep entry
    Note over Server: Timer scheduled
    Server-->>Journal: CompletionMessage (sleep done)
    Journal->>Journal: Add to journal

    Handler->>Journal: ctx.run("Reminder", fn)
    Journal->>Journal: Check journal: no entry
    Journal->>Server: RunEntry (running)
    Server->>Server: 💾 Persist entry
    Handler->>Handler: Execute sendReminder()
    Handler-->>Journal: Success!
    Journal->>Server: RunEntry (completed)
    Server->>Server: 💾 Update entry status
    Server-->>Journal: CompletionMessage
    Journal->>Journal: Add to journal

    Note over Handler: logNonDurableStep("Handler completed")<br/>⚠️ RUNS AGAIN with NEW timestamp

    Handler-->>Journal: return {result: "..."}
    Journal->>Server: OutputEntry + EndMessage
    Server->>Server: 💾 Persist final state
    deactivate Handler
    deactivate Journal
    Server-->>User: ✅ 200 OK {result: "..."}
```

## Key Observations

### What Gets Journaled (Durable)
- ✅ `ctx.rand.uuidv4()` → `GetRandomSeedEntry`
- ✅ `ctx.run()` → `RunEntry` with result
- ✅ `ctx.sleep()` → `SleepEntry`
- ✅ Return value → `OutputEntry`

**Result**: On replay, SDK returns stored values without re-executing

### What Does NOT Get Journaled (Replayed)
- ⚠️ `logNonDurableStep()` - regular code outside ctx operations
- ⚠️ `console.log()` - side effects not in ctx.run()
- ⚠️ File writes via `appendFileSync()` - not wrapped in ctx.run()

**Result**: On replay, these execute again with new timestamps!

## Protocol Messages

| Message | Direction | Purpose |
|---------|-----------|---------|
| `StartMessage` | Runtime → SDK | Begin invocation, includes journal size |
| `GetRandomSeedEntry` | SDK → Runtime | Request deterministic random seed |
| `RunEntry` | SDK → Runtime | Execute side effect (or replay result) |
| `SleepEntry` | SDK → Runtime | Durable timer |
| `CompletionMessage` | Runtime → SDK | Entry completed with result |
| `SuspensionMessage` | SDK → Runtime | Pause, waiting for retry |
| `EndMessage` | SDK → Runtime | Invocation successful |
| `OutputEntry` | SDK → Runtime | Final return value |

## Durability Guarantees

**Critical**: Each journal entry is persisted to the Restate Server **before** execution continues:

1. SDK creates journal entry → sends to Runtime
2. Runtime persists to storage → acknowledges to SDK
3. Only then does SDK proceed with next operation

This means:
- **Process crashes** → Journal is safe, resume from last persisted entry
- **Network failures** → Runtime has durable record, can retry
- **Service restarts** → Full execution history available for replay

## Why This Matters

The demo shows that:
1. **Journal entries are replayed** - same UUID, same results
2. **Regular code is re-executed** - different timestamps in `replay-log.txt`
3. **Partial progress preserved** - notification doesn't run again on resume
4. **Deterministic execution** - same inputs, same outputs, every time
5. **True durability** - every step persisted before proceeding
