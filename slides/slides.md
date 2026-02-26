---
theme: default
title: "Durable Execution: Building Apps That Refuse to Die"
info: |
  ## Durable Execution: Building Apps That Refuse to Die
  DevNexus 2026
drawings:
  persist: false
transition: slide-left
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

What happens when `sendReminder` fails?

---
clicks: 7
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
    { from: 'sdk', to: 'handler', label: 'ctx.rand.uuidv4()', type: 'request' },
    { from: 'handler', to: 'handler', label: 'sendNotification()', type: 'self' },
    { from: 'handler', to: 'handler', label: 'ctx.sleep(1s)', type: 'self' },
    { from: 'handler', to: 'handler', label: 'sendReminder()', type: 'self' },
    { from: 'handler', to: 'client', label: '200 OK', type: 'response' },
  ]"
/>

<div class="mt-8 text-sm text-gray-400">
  Press → or Space to step through the execution
</div>

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

# How Is This Different From What I'd Build Myself?

| DIY Approach | Restate |
|---|---|
| Database + message queue + orchestrator | **Single runtime** handles all three |
| You implement retries, idempotency, recovery | **Built in** — just write business logic |
| Coordinating failover across multiple systems | **One failover model** for everything |
| Tuning replication, consistency, timeouts | **Sensible defaults** that just work |

<div class="mt-6 p-4 bg-amber-50 dark:bg-amber-900 rounded">

Restate combines the **durability of a database**, the **messaging of a queue**, and the **orchestration of a workflow engine** into a single, fast runtime.

</div>

---
layout: center
---

# Questions?

Sam Dengler — [@samdengler](https://twitter.com/samdengler)
