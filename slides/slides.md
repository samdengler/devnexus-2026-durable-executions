---
theme: default
title: "Durable Execution: Building Apps That Refuse to Die"
info: |
  ## Durable Execution: Building Apps That Refuse to Die
  DevNexus 2026
drawings:
  persist: false
transition: slide-left
colorSchema: dark
duration: 20
mdc: true
---

# Durable Execution
## Building Apps That Refuse to Die

Sam Dengler

---

# The Problem

Building distributed applications is hard

- Retries — how many? With backoff? Idempotency?
- State management — where does it live? What if it's stale?
- Failure recovery — what step were we on? Can we resume?
- Orchestration — sagas, compensations, dead letter queues...

**We spend more time on plumbing than business logic.**

---

# What is Durable Execution?

Persist execution progress. Resume seamlessly after crashes.

- Your code runs **exactly as written** — normal functions, normal control flow
- The runtime journals each step as it completes
- On failure, replay from the journal — skip completed steps
- You focus on **business logic**, not infrastructure

---

# Meet Restate

A lightweight runtime for durable execution

- **Durable async/await** — write normal code, get automatic resilience
- **Journaling** — every side effect is recorded and replayed on retry
- **Virtual objects** — stateful entities with built-in K/V state
- **Workflows** — long-running operations with signals and timers

---

# Demo: Greeter Service

```ts
async (ctx: restate.Context, { name }) => {
  // Each step is durably executed
  const greetingId = ctx.rand.uuidv4();
  await ctx.run("Notification", () =>
    sendNotification(greetingId, name));
  await ctx.sleep({ seconds: 1 });
  await ctx.run("Reminder", () =>
    sendReminder(greetingId, name));
  return { result: `You said hi to ${name}!` };
}
```

---
clicks: 15
---

# Durable Execution in Action

<InteractiveSequence
  :actors="[
    { id: 'client', label: 'Client' },
    { id: 'server', label: 'Restate Server' },
    { id: 'sdk', label: 'SDK' },
    { id: 'handler', label: 'Handler' },
  ]"
  :steps="[
    { from: 'client', to: 'server', label: 'POST /Greeter/greet', type: 'request' },
    { from: 'server', to: 'sdk', label: 'invoke()', type: 'request' },
    { from: 'sdk', to: 'handler', label: 'start handler', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.rand.uuidv4()', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal UUID', type: 'request' },
    { from: 'server', to: 'sdk', label: 'ACK', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Notification)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal notification', type: 'request' },
    { from: 'server', to: 'sdk', label: 'ACK', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.sleep(1s)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal sleep', type: 'request' },
    { from: 'server', to: 'sdk', label: 'ACK', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Reminder)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal reminder', type: 'request' },
    { from: 'server', to: 'client', label: '200 OK', type: 'response' },
  ]"
/>

---

# Inside the Journal

Every invocation gets its own append-only journal

| # | Entry Type | Name | Result |
|---|-----------|------|--------|
| 0 | **Input** | | `{ name: "DevNexus" }` |
| 1 | **Run** | `uuidv4` | `"a1b2c3d4-..."` |
| 2 | **Run** | `Notification` | `void` |
| 3 | **Sleep** | | `1000ms` |
| 4 | **Run** | `Reminder` | *pending...* |

On retry, entries 0-3 are **replayed from the journal** — no re-execution. Only entry 4 runs again.

```bash
restate sql "SELECT * FROM sys_journal WHERE id = '<invocation_id>';"
```

---
clicks: 11
---

# What Happens When sendReminder Fails?

Execution fails, then resumes from the journal

<InteractiveSequence
  :actors="[
    { id: 'handler', label: 'Handler' },
    { id: 'sdk', label: 'SDK' },
    { id: 'server', label: 'Restate Server' },
  ]"
  :steps="[
    { from: 'handler', to: 'sdk', label: 'ctx.rand.uuidv4()', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal #1: UUID', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Notification)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal #2: Notification', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.sleep(1s)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'journal #3: Sleep', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Reminder)', type: 'request' },
    { from: 'handler', to: 'handler', label: 'sendReminder() fails!', type: 'self' },
    { type: 'event', label: 'Retry -- replay journal entries 1-3' },
    { from: 'sdk', to: 'handler', label: 'Replay: skip completed steps', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'Retry: ctx.run(Reminder)', type: 'request' },
  ]"
/>

---

# How Are Journal Entries Kept Safe?

Every `ctx.run()` is replicated before your code moves on

- Restate runs as a **cluster** of nodes (typically 3+)
- Each journal entry is written to **multiple nodes** simultaneously
- Restate waits for a **majority** to confirm the write before proceeding
- If one node dies, the other copies still have your data

<div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900 rounded">

**Think of it like saving a document to multiple cloud drives at once.** Your code doesn't continue until the save is confirmed. Typical latency: **~3ms**.

</div>

---
clicks: 6
---

# How Are Journal Entries Kept Safe?

Your handler talks to a **leader node**, which replicates to the cluster

<InteractiveSequence
  :actors="[
    { id: 'handler', label: 'Your Handler' },
    { id: 'leader', label: 'Leader Node' },
    { id: 'r1', label: 'Replica 1' },
    { id: 'r2', label: 'Replica 2' },
  ]"
  :steps="[
    { from: 'handler', to: 'leader', label: 'ctx.run() result', type: 'request' },
    { from: 'leader', to: 'r1', label: 'Replicate journal entry', type: 'request' },
    { from: 'leader', to: 'r2', label: 'Replicate journal entry', type: 'request' },
    { from: 'r1', to: 'leader', label: 'ACK', type: 'response' },
    { from: 'r2', to: 'leader', label: 'ACK', type: 'response' },
    { from: 'leader', to: 'handler', label: 'OK — your code continues', type: 'response' },
  ]"
/>

---

# What Happens When a Node Crashes?

Restate uses Raft consensus for automatic failover

- The cluster **detects** the failed node via health checks
- The old leader is **sealed** and a new leader is elected
- The new leader **promotes** a follower and rebuilds state from the journal
- Your handler **reconnects** seamlessly

---
clicks: 9
---

# What Happens When a Node Crashes?

<InteractiveSequence
  :actors="[
    { id: 'app', label: 'Your Handler' },
    { id: 'n1', label: 'Node 1 (Leader)' },
    { id: 'n2', label: 'Node 2' },
    { id: 'n3', label: 'Node 3' },
  ]"
  :steps="[
    { from: 'app', to: 'n1', label: 'ctx.run() -- step 3', type: 'request' },
    { from: 'n1', to: 'n1', label: 'Node 1 crashes!', type: 'self' },
    { type: 'event', label: 'Heartbeat timeout detected' },
    { from: 'n3', to: 'n2', label: 'RequestVote', type: 'request' },
    { from: 'n2', to: 'n3', label: 'VoteGranted', type: 'response' },
    { type: 'event', label: 'Old leader sealed -- Node 2 elected' },
    { from: 'n2', to: 'n2', label: 'Rebuild state from journal', type: 'self' },
    { from: 'n2', to: 'app', label: 'Replays journal -- skips steps 1-2', type: 'response' },
    { from: 'app', to: 'n2', label: 'Re-executes step 3', type: 'request' },
  ]"
/>

---

# The Three Guarantees

What Restate promises about resilience

<div class="grid grid-cols-3 gap-6 mt-8">

<div class="p-4 border rounded text-center">

### No Lost Work

Every committed step is stored on multiple nodes. A single node failure **cannot lose data**.

</div>

<div class="p-4 border rounded text-center">

### No Double Execution

On recovery, completed steps are **replayed from the journal**, not re-executed. Side effects don't repeat.

</div>

<div class="p-4 border rounded text-center">

### Fast Failover

A standby node can take over in **seconds**, not minutes. Your in-flight invocations resume automatically.

</div>

</div>

<div class="mt-6 text-center text-sm opacity-60">

No saga patterns. No dead letter queues. No manual recovery scripts.

</div>

---

# Recap

- Write **normal code** — journaling persists every step
- **Raft consensus** replicates across nodes
- **Automatic failover** — handler reconnects seamlessly

---
layout: center
---

# See the Full Talk at DevNexus!

**Durable Execution: Building Apps That Refuse to Die**

March 14 in Atlanta

[Session link](https://devnexus.com) | [Schedule](https://devnexus.com/schedule)

Sam Dengler — [@samdengler](https://twitter.com/samdengler)
