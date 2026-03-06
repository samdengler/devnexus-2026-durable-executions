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

DevNexus 2026

---

# About Me

<div class="flex gap-8 items-start">
<div>
<img src="/avatar.png" class="rounded-full w-40 h-40" />
</div>
<div>

**Sam Dengler**
<br>Sr Principal Engineer, JPMorganChase

AI engineering, event-driven architectures, distributed systems, AWS, serverless

@samdengler
<br>[Twitter](https://twitter.com/samdengler) / [LinkedIn](https://linkedin.com/in/samdengler) / [GitHub](https://github.com/samdengler)

</div>
</div>

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
clicks: 2
---

# Demo: Greeter Service

<div style="height:340px">
<div v-if="$clicks === 0">

```ts
// TypeScript
async (ctx: restate.Context, { name }) => {
  const greetingId = ctx.rand.uuidv4();

  await ctx.run("Notification", () =>
    sendNotification({ idempotencyKey: greetingId, name })
  );

  await ctx.run("Reminder", () =>
    sendReminder({ idempotencyKey: greetingId, name })
  );

  return { result: `You said hi to ${name}!` };
}
```

</div>
<div v-if="$clicks === 1">

```python
# Python
@greeter.handler()
async def greet(ctx: restate.Context, name: str) -> str:
  greeting_id = ctx.uuid()

  await ctx.run_typed("Notification",
    lambda: send_notification(idempotency_key=greeting_id, name=name)
  )

  await ctx.run_typed("Reminder",
    lambda: send_reminder(idempotency_key=greeting_id, name=name)
  )

  return f"You said hi to {name}!"
```

</div>
<div v-if="$clicks >= 2">

```java
// Java
record Notification(String idempotencyKey, String name) {}
record Reminder(String idempotencyKey, String name) {}

@Handler
public String greet(Context ctx, String name) {
  var greetingId = ctx.random().nextUUID().toString();

  ctx.run("Notification", () ->
    sendNotification(new Notification(greetingId, name))
  );

  ctx.run("Reminder", () ->
    sendReminder(new Reminder(greetingId, name))
  );

  return "You said hi to " + name + "!";
}
```

</div>
</div>

<div class="flex items-center justify-center gap-0 mt-8">
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Your Code</div>
<svg width="180" height="24" class="shrink-0" style="vertical-align:middle">
  <line x1="0" y1="12" x2="172" y2="12" stroke="#38bdf8" stroke-width="1.5" />
  <polygon points="172,12 166,9 166,15" fill="#38bdf8" />
</svg>
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">SDK (ctx)</div>
<div class="shrink-0 relative" style="width:180px">
  <span class="text-xs absolute w-full text-center" style="color:#38bdf8;font-weight:500;top:-14px">HTTP/2 + Protobuf</span>
  <svg width="180" height="6" style="display:block">
    <line x1="0" y1="3" x2="172" y2="3" stroke="#38bdf8" stroke-width="1.5" />
    <polygon points="172,3 166,0 166,6" fill="#38bdf8" />
  </svg>
</div>
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Restate Server</div>
</div>

---

# Local Architecture

<div class="flex items-center justify-center gap-8 mt-12">

<div class="p-6 border-2 border-blue-400 rounded-lg text-center w-40">
<div class="text-2xl mb-2">Client</div>
<div class="text-sm text-gray-400">curl / httpie</div>
</div>

<div class="text-2xl text-gray-500">→</div>

<div class="p-6 border-2 border-purple-400 rounded-lg text-center w-52">
<div class="text-2xl mb-2">Restate Server</div>
<div class="text-sm text-gray-400">localhost:8080</div>
</div>

<div class="text-2xl text-gray-500">→</div>

<div class="p-6 border-2 border-yellow-400 rounded-lg text-center w-52">
<div class="text-2xl mb-4">Service</div>
<div class="p-3 border border-gray-500 rounded text-sm">
<div class="font-semibold">Handler</div>
<div class="text-gray-400 text-xs mt-1">SDK (ctx)</div>
</div>
<div class="text-sm text-gray-400 mt-2">localhost:9080</div>
</div>

</div>

---

# Demo: Starting the Stack

<div></div>

Start the service:

```bash
cd demos/01-durable-execution && npm run dev
```

Start Restate:

```bash
restate up
```

Register the service:

```bash
restate deployments register http://localhost:9080
```

<!--
**Before the talk:**
1. Run `./bin/demo.sh` to start tmux with all panes
2. The script starts Restate server (top-left) and service (top-right)
3. Use the bottom pane for commands
4. Register: `restate deployments register http://localhost:9080`
5. Verify: open Restate UI at http://localhost:9070/ — Greeter service should appear
-->

---

# Demo: Trigger a Failure

<div></div>

Enable failure mode:

```bash
touch demos/01-durable-execution/FAIL_DEMO
```

Invoke the greeter (async):

```bash
http POST localhost:8080/Greeter/greet/send name=DevNexus
```

Check invocation status:

```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

<!--
**Speaker notes:**
- Create FAIL_DEMO flag file to make sendNotification throw
- Use /send so we get 202 Accepted immediately
- The handler will crash during the Notification step
- Show the Restate UI: invocation is retrying
- Then advance to the sequence diagram to explain what happened
-->

---
clicks: 18
---

# Durable Execution in Action (Async)

<InteractiveSequence
  :actors="[
    { id: 'client', label: 'Client' },
    { id: 'server', label: 'Restate Server', minWidth: 160 },
    { id: 'sdk', label: 'SDK' },
    { id: 'handler', label: 'Handler' },
  ]"
  :steps="[
    { from: 'client', to: 'server', label: 'POST /Greeter/greet/send', type: 'request' },
    { from: 'server', to: 'server', label: 'append_log(invocation)', type: 'self' },
    { from: 'server', to: 'client', label: '202 Accepted', type: 'response' },
    { from: 'server', to: 'sdk', label: 'StartMessage(journal_entries: 0)', type: 'request' },
    { from: 'sdk', to: 'handler', label: 'handler.invoke(ctx, journal #0)', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.rand.uuidv4()', type: 'request' },
    { from: 'handler', to: 'handler', label: 'generate UUID (Idempotency-Key)', type: 'self' },
    { from: 'sdk', to: 'server', label: 'RunCommand(UUID)', type: 'request' },
    { from: 'server', to: 'server', label: 'append_log(UUID)', type: 'self', side: 'left' },
    { from: 'server', to: 'sdk', label: 'Completion(UUID)', type: 'response' },
    { from: 'sdk', to: 'handler', label: 'journal #1 UUID', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Notification)', type: 'request' },
    { from: 'handler', to: 'handler', label: 'sendNotification(Idempotency-Key)', type: 'self' },
    { from: 'sdk', to: 'server', label: 'RunCommand(Notification)', type: 'request' },
    { from: 'server', to: 'server', label: 'append_log(Notification)', type: 'self', side: 'left' },
    { from: 'server', to: 'sdk', label: 'Completion(Notification)', type: 'response' },
    { from: 'sdk', to: 'handler', label: 'journal #2 Notification', type: 'response' },
    { type: 'event', label: 'Handler crashes!' },
  ]"
/>

---

# Inside the Journal

Every invocation gets its own append-only journal

| # | Entry Type | Name | Result |
|---|-----------|------|--------|
| 0 | **Input** | | `{ name: "DevNexus" }` |
| 1 | **Run** | `uuidv4` | `"a1b2c3d4-..."` |
| 2 | **Run** | `Notification` | `{ status: "sent" }` |

---

# Demo: Fix the Failure

<div></div>

Remove the failure flag:

```bash
rm demos/01-durable-execution/FAIL_DEMO
```

Check invocation status:

```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

<!--
**Speaker notes:**
- Remove FAIL_DEMO so the next retry succeeds
- Restate will automatically retry the invocation
- Show the Restate UI: invocation completes successfully
- Then advance to the Replay slide to explain what happened
-->

---
clicks: 16
---

# Durable Execution: Replay

<InteractiveSequence
  :actors="[
    { id: 'client', label: 'Client' },
    { id: 'server', label: 'Restate Server', minWidth: 160 },
    { id: 'sdk', label: 'SDK' },
    { id: 'handler', label: 'Handler' },
  ]"
  :steps="[
    { from: 'server', to: 'sdk', label: 'StartMessage(journal_entries: 3)', type: 'request' },
    { from: 'sdk', to: 'handler', label: 'handler.invoke(ctx, journal #0)', type: 'request' },
    { from: 'handler', to: 'sdk', label: 'ctx.rand.uuidv4()', type: 'request' },
    { from: 'sdk', to: 'handler', label: 'journal #1 UUID', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Notification)', type: 'request' },
    { from: 'sdk', to: 'handler', label: 'journal #2 Notification', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'ctx.run(Reminder)', type: 'request' },
    { from: 'handler', to: 'handler', label: 'sendReminder(Idempotency-Key)', type: 'self' },
    { from: 'sdk', to: 'server', label: 'RunCommand(Reminder)', type: 'request' },
    { from: 'server', to: 'server', label: 'append_log(Reminder)', type: 'self', side: 'left' },
    { from: 'server', to: 'sdk', label: 'Completion(Reminder)', type: 'response' },
    { from: 'sdk', to: 'handler', label: 'journal #3 Reminder', type: 'response' },
    { from: 'handler', to: 'sdk', label: 'return Result', type: 'request' },
    { from: 'sdk', to: 'server', label: 'OutputCommand(Result)', type: 'request' },
    { from: 'sdk', to: 'server', label: 'EndMessage', type: 'request' },
    { from: 'server', to: 'server', label: 'append_log(Result)', type: 'self', side: 'left' },
  ]"
/>

---

# Inside the Journal (after replay)

Invocation complete — all entries durably persisted

| # | Entry Type | Name | Result |
|---|-----------|------|--------|
| 0 | **Input** | | `{ name: "DevNexus" }` |
| 1 | **Run** | `uuidv4` | `"a1b2c3d4-..."` |
| 2 | **Run** | `Notification` | `{ status: "sent" }` |
| 3 | **Run** | `Reminder` | `{ status: "sent" }` |
| 4 | **Output** | | `{ result: "You said hi to DevNexus!" }` |

---

# Demo: Live

<div></div>

Register the service with Restate:

```bash
restate deployments register http://localhost:9080
```

Invoke the greeter (async):

```bash
http POST localhost:8080/Greeter/greet/send name=DevNexus
```

Check invocation status:

```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

Invoke with failure simulation:

```bash
http POST localhost:8080/Greeter/greet/send name=Alice
```

<!--
**Setup:** run `./bin/demo.sh` before talk

**Restate UI walkthrough:**

1. Open http://localhost:9070/
2. After registering, show the **Services** tab — Greeter service appears
3. After invoking DevNexus, show **Invocations** — completed successfully
4. After invoking Alice, show **Invocations** — watch retries in real-time
5. Click into the Alice invocation to show journal entries and retry attempts
-->

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
