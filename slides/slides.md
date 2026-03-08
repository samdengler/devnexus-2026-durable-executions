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

Agentic engineering, event-driven architectures, distributed systems, AWS, serverless

@samdengler
<br>[Twitter](https://twitter.com/samdengler) / [LinkedIn](https://linkedin.com/in/samdengler) / [GitHub](https://github.com/samdengler)

</div>
</div>

<div class="flex justify-end mt-4 mr-8">
<div class="text-center">
<img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https://samdengler.github.io/devnexus-2026-durable-executions/" class="w-28 h-28" />
<div class="text-xs mt-1 text-slate-400">Slides</div>
</div>
</div>

---
clicks: 1
---

# The Simple Life

<div class="flex items-center justify-center mt-8">
<div v-if="$clicks < 1" class="text-center relative">
<img src="/bambi.png" class="h-56 mx-auto" />
<div class="absolute" style="top:8%;right:12%">
<span style="color:#b91c1c;font-size:16px;font-weight:700">Your App</span>
<svg width="80" height="70" style="display:block"><line x1="40" y1="5" x2="10" y2="60" stroke="#b91c1c" stroke-width="2.5" /><polygon points="10,60 17,53 11,50" fill="#b91c1c" /></svg>
</div>
</div>
<div v-if="$clicks >= 1" class="text-center relative">
<img src="/godzilla.png" class="h-56 mx-auto" />
<div class="absolute" style="top:8%;right:12%">
<span style="color:#b91c1c;font-size:16px;font-weight:700">Reality</span>
<svg width="80" height="70" style="display:block"><line x1="30" y1="5" x2="10" y2="60" stroke="#b91c1c" stroke-width="2.5" /><polygon points="10,60 17,53 11,50" fill="#b91c1c" /></svg>
</div>
</div>
</div>

<div v-if="$clicks < 1" class="text-center mt-6 text-yellow-400 text-base font-medium">No network calls. No retries. No failures. Life is good.</div>
<div v-if="$clicks >= 1" class="text-center mt-6 text-red-400 text-base font-medium">Then distributed systems happen.</div>

<div class="absolute bottom-4 right-6 text-xs text-slate-600"><a href="https://tvtropes.org/pmwiki/pmwiki.php/WesternAnimation/BambiMeetsGodzilla">Bambi Meets Godzilla</a></div>

---

# The Problem

Building distributed applications is hard

- Retries — how many? With backoff? Idempotency?
- State management — where does it live? What if it's stale?
- Failure recovery — what step were we on? Can we resume?
- Orchestration — sagas, compensations, dead letter queues...

**We spend more time on plumbing than business logic.**

<div class="flex items-center justify-center gap-0 mt-8">
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Service A</div>
<div class="shrink-0 relative" style="width:300px">
  <span class="text-xs absolute w-full text-center" style="color:#f87171;font-weight:500;top:-14px">retries? timeouts? idempotency? ordering?</span>
  <svg width="300" height="24" style="display:block"><line x1="0" y1="12" x2="292" y2="12" stroke="#38bdf8" stroke-width="1.5" /><polygon points="292,12 286,9 286,15" fill="#38bdf8" /></svg>
  <span class="text-xs absolute w-full text-center" style="color:#f87171;font-weight:500;bottom:-14px">state? recovery? compensation? dead letters?</span>
</div>
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Service B</div>
</div>

---
clicks: 2
---

# What is Durable Execution?

Persist execution progress. Resume seamlessly after crashes.

- Your code runs **exactly as written** — normal functions, normal control flow
- The runtime journals each step as it completes
- On failure, replay from the journal — skip completed steps
- Growing ecosystem: [Temporal](https://temporal.io), [Restate](https://restate.dev), [Azure Durable Functions](https://learn.microsoft.com/azure/azure-functions/durable/), [AWS Lambda Durable Functions](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-durable-functions/), [Inngest](https://inngest.com), [DBOS](https://dbos.dev), [Vercel Workflow SDK](https://vercel.com/docs/workflow-sdk), [Cloudflare Workflows](https://developers.cloudflare.com/workflows/)

<div class="mt-6 text-slate-400">

<div v-if="$clicks >= 1" class="mb-2">

1. Not a new idea — transaction logs, event sourcing, sagas (nothing is new... except maybe Claude Code?)

</div>
<div v-if="$clicks >= 2">

2. Not a silver bullet — don't @ me about why this won't work for your use case

</div>

</div>

<div class="absolute bottom-8 left-0 right-0 text-center text-yellow-400 text-base font-medium">More time on business logic, less on distributed systems plumbing.</div>

---

# Meet Restate

<img src="/logos/restate.png" class="w-16 float-right mt-[-1rem]" />

A lightweight runtime for durable execution

- **Durable async/await** — write normal code, get automatic resilience
- **Journaling** — every side effect is recorded and replayed on retry
- **Virtual objects** — stateful entities with built-in K/V state
- **Workflows** — long-running operations with signals and timers
- Built by the creators of **Apache Flink** — bringing stream processing reliability to application backends

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
1. Run `./bin/demo.sh` to start tmux session "devnexus"
2. Window 0 (Demo): code viewer (top pane) + command pane (bottom)
3. Window 1 (Services): restate-server (top pane) + npm run dev service logs (bottom)
4. Restate UI opens automatically in cmux browser at http://localhost:9070/
5. Switch to command pane (Window 0, bottom) and register:
   `restate deployments register http://localhost:9080`
6. Verify: Greeter service should appear in the Restate UI

**Reset between runs:**
```
restate invocations cancel Greeter --kill --yes
restate invocations purge Greeter --yes
```
-->

---

# Demo: Trigger a Failure

<div></div>

Enable failure mode:

```bash
touch FAIL_DEMO
```

Invoke the greeter (async):

```bash
http POST localhost:8080/Greeter/greet/send name=DevNexus
```

Check invocation status:

```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

Kill the service (Ctrl+C in Services window)

<!--
**Speaker notes:**
- Replace INVOCATION_ID with the id from the x-restate-id header or JSON response
- Create FAIL_DEMO flag file so handler stalls before Reminder step
- Use /send so we get 202 Accepted immediately
- The handler will be waiting — kill the service to simulate a crash
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

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right flex flex-col gap-1 items-end"><a href="https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying">The Log: What Every Software Engineer Should Know (Kreps, 2013)</a><a href="https://restate.dev/blog/replicated-loglet/">Bifrost: Restate's Replicated Log (Rohrmann, 2024)</a></div>

---

# Demo: Fix the Failure

<div></div>

Remove the failure flag:

```bash
rm FAIL_DEMO
```

Restart the service:

```bash
npm run dev
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

# What About the Logs?

Logs inside and outside `ctx.run()` behave differently on replay

```ts {all|2|4-7|9-12}
async (ctx: restate.Context, { name }) => {
  log(`Handler started for ${name}`);          // runs EVERY time

  await ctx.run("Notification", () => {
    log(`Sending notification for ${greetingId}`);  // skipped on replay
    sendNotification({ idempotencyKey: greetingId, name });
  });

  await ctx.run("Reminder", () => {
    log(`Sending reminder for ${greetingId}`);      // skipped on replay
    sendReminder({ idempotencyKey: greetingId, name });
  });
}
```

- **Outside `ctx.run()`** — re-executes on every replay
- **Inside `ctx.run()`** — skipped when replaying from journal

<!--
Show the replay log: cat demo-log.txt
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

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right flex flex-col gap-1 items-end"><a href="https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf">Consistency Tradeoffs in Modern Distributed Database System Design (Abadi, 2012)</a><a href="https://arxiv.org/pdf/2109.07771">Quantifying and Generalizing the CAP Theorem (Sharov et al., 2021)</a></div>

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
- The old leader is **sealed** and a new leader is elected via **Raft** consensus
- The new leader rebuilds state from the journal — your handler **reconnects** seamlessly

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right flex flex-col gap-1 items-end"><a href="https://raft.github.io/raft.pdf">In Search of an Understandable Consensus Algorithm (Ongaro & Ousterhout, 2014)</a><a href="https://research.facebook.com/publications/delos-distributed-log-based-consensus-for-replicated-state-machines/">Delos: Distributed Log-based Consensus (Balakrishnan et al., 2020)</a></div>

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

# Virtual Objects

Stateful entities with a single writer — like an actor with durable K/V state

```ts {all|3-7|9-14}
const counter = restate.object({ name: "Counter", handlers: {

  add: async (ctx: restate.ObjectContext, value: number) => {
    const current = (await ctx.get<number>("count")) ?? 0;
    ctx.set("count", current + value);
    return current + value;
  },

  // Signal handler — receives events, runs with exclusive access
  notify: async (ctx: restate.ObjectContext, event: string) => {
    const log = (await ctx.get<string[]>("events")) ?? [];
    log.push(event);
    ctx.set("events", log);
  },
}});
```

- Keyed by ID — `POST /Counter/my-counter/add`
- **Exclusive access** per key — no races, no locks
- Built-in K/V state via `ctx.get()` / `ctx.set()`

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/foundations/services">docs.restate.dev/foundations/services</a></div>

---

# Workflows

Like our Greeter handler, but with **durable promises** and **signal handlers**

```ts {all|3-8|10-13}
const checkout = restate.workflow({ name: "Checkout", handlers: {

  run: async (ctx: restate.WorkflowContext, order: Order) => {
    await ctx.run("reserve", () => reserveInventory(order));
    const payment = await ctx.promise<Payment>("payment"); // wait for signal
    await ctx.run("fulfill", () => fulfillOrder(order, payment));
    return { status: "completed" };
  },

  // Signal handler — called externally to unblock the workflow
  confirmPayment: async (ctx: restate.SharedWorkflowContext, payment: Payment) => {
    ctx.promise<Payment>("payment").resolve(payment);
  },
}});
```

- **What's new vs Greeter?** `ctx.promise()` suspends until signaled — no polling
- Each workflow run has a **durable ID** — at-most-once execution
- Signal handlers can unblock waiting workflows from any source

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/develop/ts/workflows/">docs.restate.dev/develop/ts/workflows</a></div>

---

# Orchestrating Microservices

Integrate with your existing services and infrastructure

```ts
async (ctx: restate.Context, order: Order) => {
  // Call any HTTP API — each ctx.run() is journaled and retried
  const inventory = await ctx.run("check inventory",
    () => fetch("https://inventory-svc/check", { method: "POST", body: order }));

  const payment = await ctx.run("charge payment",
    () => fetch("https://payments-svc/charge", { method: "POST", body: order }));

  const shipment = await ctx.run("create shipment",
    () => fetch("https://shipping-svc/ship", { method: "POST", body: order }));

  return { inventory, payment, shipment };
}
```

- Downstream services are **plain HTTP APIs** — no SDK needed
- Each `ctx.run()` retries on failure with the same idempotency key
- Restate is the **orchestrator**, not a runtime for every service

---

# Event-Driven Architectures

Process Kafka events as durable invocations

```ts
const events = restate.service({
  name: "EventProcessor",
  handlers: {
    process: async (ctx: restate.Context, event: PaymentEvent) => {
      ctx.workflowClient(checkout, event.orderId)
        .confirmPayment(event);
    },
  },
});
```

```bash
# Subscribe: topic → EventProcessor/process handler
restate subscriptions create kafka-topic EventProcessor/process
```

- Restate manages offsets — exactly-once processing (or bring your own consumer)
- Each message becomes a **durable invocation**

<div class="flex items-center justify-center gap-0 mt-4">
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Kafka Topic</div>
<div class="shrink-0 relative" style="width:140px">
  <span class="text-xs absolute w-full text-center" style="color:#38bdf8;font-weight:500;top:-14px">subscribe</span>
  <svg width="140" height="24" style="display:block"><line x1="0" y1="12" x2="132" y2="12" stroke="#38bdf8" stroke-width="1.5" /><polygon points="132,12 126,9 126,15" fill="#38bdf8" /></svg>
</div>
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Restate</div>
<div class="shrink-0 relative" style="width:140px">
  <span class="text-xs absolute w-full text-center" style="color:#38bdf8;font-weight:500;top:-14px">invoke</span>
  <svg width="140" height="24" style="display:block"><line x1="0" y1="12" x2="132" y2="12" stroke="#38bdf8" stroke-width="1.5" /><polygon points="132,12 126,9 126,15" fill="#38bdf8" /></svg>
</div>
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">EventProcessor</div>
</div>

---

# Recipe: Saga Pattern

Compensating actions on failure — no framework needed

```ts {all|4-5,7-8|10-11,16|10-15}
async (ctx: restate.Context, booking: Booking) => {
  const compensations: (() => Promise<void>)[] = [];

  const flight = await ctx.run("book flight", () => bookFlight(booking));
  compensations.push(() => ctx.run("cancel flight", () => cancelFlight(flight)));

  const hotel = await ctx.run("book hotel", () => bookHotel(booking));
  compensations.push(() => ctx.run("cancel hotel", () => cancelHotel(hotel)));

  try {
    const car = await ctx.run("rent car", () => rentCar(booking));
  } catch (e) {
    for (const undo of compensations.reverse()) await undo();
    throw e;
  }
  return { flight, hotel, car };
}
```

- Each compensation is **journaled** — won't repeat on retry
- Normal try/catch — no saga orchestrator needed

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/guides/sagas">docs.restate.dev/guides/sagas</a></div>

---

# Recipe: Cron Job

Durable sleep + recurring execution

```ts
const cron = restate.service({
  name: "CronJob",
  handlers: {
    run: restate.createServiceHandler(
      async (ctx: restate.Context) => {
        while (true) {
          await ctx.run("task", () => doPeriodicWork());

          // Durable sleep — survives crashes and restarts
          await ctx.sleep(60_000); // 1 minute
        }
      }
    ),
  },
});
```

- `ctx.sleep()` is **durable** — persisted in the journal
- Survives process restarts, node failures, deployments
- No external scheduler needed

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/guides/cron">docs.restate.dev/guides/cron</a></div>

---

# Parallel Work

Fan-out concurrent tasks, gather results durably

```ts
async (ctx: restate.Context, urls: string[]) => {
  // Fan out — each call is a separate durable invocation
  const promises = urls.map(url =>
    ctx.serviceClient(Fetcher).fetch(url)
  );

  // Gather results — all or nothing
  const results = await Promise.all(promises);

  await ctx.run("aggregate", () => saveResults(results));
  return results;
}
```

- Each sub-invocation is **independently durable**
- Parent resumes from journal — no re-fetching completed results
- Failures in one branch don't lose progress in others

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/guides/parallelizing-work">docs.restate.dev/guides/parallelizing-work</a></div>

---

# Durable Webhooks

Any handler can be a webhook processor — just point your webhook at Restate

```ts {all|3-7|10}
// Webhook router — receives events, routes to the right processor
onStripeEvent: async (ctx: restate.Context, event: StripeEvent) => {
  if (event.type === "invoice.payment_failed") {
    ctx.objectSendClient(PaymentTracker, event.data.object.id)
      .onPaymentFailed(event);
  } else if (event.type === "invoice.payment_succeeded") {
    ctx.objectSendClient(PaymentTracker, event.data.object.id)
      .onPaymentSuccess(event);
  }
}
```

```
POST restate:8080/WebhookRouter/onStripeEvent
```

- `objectSendClient()` — durable one-way message, guaranteed delivery
- Each event becomes a **durable invocation** — no lost webhooks
- Virtual object keyed by ID — events for the same entity are serialized

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/guides/durable-webhooks">docs.restate.dev/guides/durable-webhooks</a></div>

---

# Process Control

Manage invocations at runtime — pause, resume, cancel, restart

<div class="grid grid-cols-2 gap-6 mt-6">
<div>

**CLI**
```bash
# Pause a running invocation
restate invocations cancel inv_1abc..

# Resume / restart as new
restate invocations purge inv_1abc..

# Cancel all for a handler
restate invocations cancel Greeter/greet
```

</div>
<div>

**Programmatic**
```ts
// Cancel from code
ctx.serviceSendClient(Greeter)
  .greet({ name }, restate.rpc.opts({ cancel: true }));
```

**Admin API**
```bash
# Pause / resume via HTTP
curl -X POST localhost:9070/invocations/inv_.../cancel
```

</div>
</div>

- Full **observability** — list, inspect, and filter invocations
- **Idempotency keys** — safely retry from the client side

<div class="absolute bottom-6 right-12 text-xs text-sky-400 text-right"><a href="https://docs.restate.dev/operate/invocation/">docs.restate.dev/operate/invocation</a></div>

---

# Deployment Topologies

Run Restate your way — from a single binary to a production cluster

<div class="flex items-center justify-center gap-16 mt-6">
<div class="text-center">

**Single Server**

<div class="flex flex-col items-center gap-2">
<div class="px-6 py-3 border border-yellow-400 rounded text-sm" style="background:#1e293b">Restate Server</div>
</div>

<div class="text-xs mt-2 text-slate-400">Dev, testing, small workloads</div>

</div>
<div class="text-center">

**Clustered**

<div class="flex flex-col items-center gap-2">
<div class="flex gap-2">
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Node 1</div>
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Node 2</div>
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Node 3</div>
</div>
</div>

<div class="text-xs mt-2 text-slate-400">HA with Raft consensus</div>

</div>
<div class="text-center">

**Disaggregated**

<div class="flex flex-col items-center gap-2">
<div class="flex gap-1">
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Meta</div>
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Workers</div>
<div class="px-3 py-2 border border-yellow-400 rounded text-xs" style="background:#1e293b">Log</div>
</div>
</div>

<div class="text-xs mt-2 text-slate-400">Scale components independently</div>

</div>
</div>

<div class="mt-8">

- **Disaggregated** — separate meta, workers, and log nodes; scale each tier independently
- **Kubernetes operator** — first-class K8s support for platform teams
- **Restate Cloud** available as a fully managed service

</div>

---

# Handler Execution

Handlers are just HTTP endpoints — deploy and scale them however you want

<div class="flex items-center justify-center gap-0 mt-8">
<div class="px-4 py-2 border border-yellow-400 rounded text-sm" style="background:#1e293b">Restate</div>
<div class="shrink-0 relative" style="width:160px">
  <span class="text-xs absolute w-full text-center" style="color:#38bdf8;font-weight:500;top:-14px">discovers & invokes</span>
  <svg width="160" height="24" style="display:block"><line x1="0" y1="12" x2="152" y2="12" stroke="#38bdf8" stroke-width="1.5" /><polygon points="152,12 146,9 146,15" fill="#38bdf8" /></svg>
</div>
<div class="flex flex-col gap-2">
<div class="px-3 py-1 border border-slate-500 rounded text-xs" style="background:#1e293b">Containers / VMs</div>
<div class="px-3 py-1 border border-slate-500 rounded text-xs" style="background:#1e293b">AWS Lambda / Cloud Functions</div>
<div class="px-3 py-1 border border-slate-500 rounded text-xs" style="background:#1e293b">Bare metal</div>
</div>
</div>

- **Register** deployments via CLI or API — Restate auto-discovers handlers
- **Versioning** — register new deployments; in-flight invocations finish on the old version
- **Scaling** — add handler replicas freely; Restate load-balances across them

---

# Recap

- Write **normal code** — journaling persists every step
- **Raft consensus** replicates across nodes
- **Automatic failover** — handler reconnects seamlessly

---
layout: center
---

# Thank You!

**Durable Execution: Building Apps That Refuse to Die**

<div class="flex justify-center items-center gap-12 mt-8">

<div class="text-center">
<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://devnexus.com" class="w-40 h-40 mx-auto" />
<div class="text-sm mt-2 opacity-60">Session link</div>
</div>

<div class="text-left space-y-4">

<div class="flex items-center gap-2">
<carbon-logo-github class="text-xl" />
<a href="https://github.com/samdengler/durable-execution">samdengler/durable-execution</a>
</div>

<div class="flex items-center gap-2">
<carbon-link class="text-xl" />
<a href="https://restate.dev">restate.dev</a>
</div>

<div class="flex items-center gap-2">
<carbon-user-avatar class="text-xl" />
Sam Dengler — <a href="https://twitter.com/samdengler">@samdengler</a>
</div>

</div>

</div>

---

# Appendix: Rate Limiting

Control concurrency with virtual objects

```ts
const rateLimiter = restate.object({ name: "RateLimiter", handlers: {

  acquire: async (ctx: restate.ObjectContext) => {
    const count = (await ctx.get<number>("inflight")) ?? 0;
    if (count >= 10) {
      await ctx.sleep(1_000); // durable back-pressure
      return ctx.objectClient(RateLimiter, ctx.key).acquire();
    }
    ctx.set("inflight", count + 1);
  },

  release: async (ctx: restate.ObjectContext) => {
    const count = (await ctx.get<number>("inflight")) ?? 0;
    ctx.set("inflight", Math.max(0, count - 1));
  },
}});
```

- Virtual object = **single writer per key** — no race conditions
- Durable sleep for back-pressure — callers wait, never dropped

---

# Appendix: Saga Pattern — How It Works

Push compensations onto a stack, pop to rewind on failure

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

**Happy path**
```
1. bookFlight()    → push cancelFlight
2. bookHotel()     → push cancelHotel
3. rentCar()       → success!
   return { flight, hotel, car }
```

</div>
<div>

**Failure at step 3**
```
1. bookFlight()    → push cancelFlight  ✓
2. bookHotel()     → push cancelHotel   ✓
3. rentCar()       → throws!
   ↓ unwind stack:
   cancelHotel()                        ✓
   cancelFlight()                       ✓
```

</div>
</div>

- Compensations run in **reverse order** — last booked, first cancelled
- Each `ctx.run()` is journaled — safe across crashes and retries

---

# Demo Cheatsheet

<div class="grid grid-cols-2 gap-x-6 gap-y-2 text-sm">
<div>

**Setup**
```bash
restate deployments register http://localhost:9080
```

**Trigger Failure**
```bash
touch FAIL_DEMO
```
```bash
http POST localhost:8080/Greeter/greet/send name=DevNexus
```
```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```
```bash
kill $(lsof -ti :9080)
```

</div>
<div>

**Fix Failure**
```bash
rm FAIL_DEMO
```
```bash
npm run dev
```
```bash
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

**Replay Logs**
```bash
cat demo-log.txt
```

**Reset Restate**
```bash
restate invocations cancel Greeter --kill --yes 2>/dev/null; restate invocations purge Greeter --yes 2>/dev/null
```

</div>
</div>
