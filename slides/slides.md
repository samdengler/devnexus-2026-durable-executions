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

DevNexus 2026

---
layout: two-cols-header
---

# About Me

<img src="/avatar.png" class="rounded-full w-40 h-40" />

::left::

**Sam Dengler**
<br>Sr Principal Engineer, JPMorganChase

AWS, serverless, event-driven architectures, distributed systems, AI engineering

::right::

@samdengler
<br>[Twitter](https://twitter.com/samdengler) / [LinkedIn](https://linkedin.com/in/samdengler) / [GitHub](https://github.com/samdengler)

---

# Agenda

Durable Execution

1. Introduction
2. Developer Experience
3. Resiliency and Failover

---

# The Problem

Building distributed applications is hard

<v-clicks>

- Retries — how many? With backoff? Idempotency?
- State management — where does it live? What if it's stale?
- Failure recovery — what step were we on? Can we resume?
- Orchestration — sagas, compensations, dead letter queues...

</v-clicks>

<v-click>

**We spend more time on plumbing than business logic.**

</v-click>

---

# What is Durable Execution?

Persist execution progress. Resume seamlessly after crashes.

<v-clicks>

- Your code runs **exactly as written** — normal functions, normal control flow
- The runtime journals each step as it completes
- On failure, replay from the journal — skip completed steps
- You focus on **business logic**, not infrastructure

</v-clicks>

---

# The Landscape

Durable execution is a growing space

<div class="relative mt-12">
  <!-- Normal state -->
  <div v-click.hide="1" class="grid grid-cols-3 gap-8 text-center">
    <div class="p-4 flex flex-col items-center gap-2">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #141414;">
        <img src="/logos/temporal.png" class="h-14 w-14 rounded-full object-cover" alt="Temporal" />
      </div>
      <span>Temporal</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #CF6A18;">
        <img src="/logos/aws-lambda.png" class="h-14 w-14 rounded-full object-cover" alt="Lambda Durable Functions" />
      </div>
      <span>Lambda Durable Functions</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #171717;">
        <img src="/logos/inngest.png" class="h-14 w-14 rounded-full object-cover" alt="Inngest" />
      </div>
      <span>Inngest</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #1E2533;">
        <img src="/logos/dbos.png" class="h-14 w-14 rounded-full object-cover" alt="DBOS" />
      </div>
      <span>DBOS</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center overflow-hidden" style="background-color: #ffffff;">
        <img src="/logos/restate.png" class="h-14 w-14 object-cover" alt="Restate" />
      </div>
      <span>Restate</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2">
      <span class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center text-2xl">+</span>
      <span>and others...</span>
    </div>
  </div>
  <!-- Highlighted state -->
  <div v-click="1" class="absolute inset-0 grid grid-cols-3 gap-8 text-center">
    <div class="p-4 flex flex-col items-center gap-2 opacity-20">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #141414;">
        <img src="/logos/temporal.png" class="h-14 w-14 rounded-full object-cover" alt="Temporal" />
      </div>
      <span>Temporal</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2 opacity-20">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #CF6A18;">
        <img src="/logos/aws-lambda.png" class="h-14 w-14 rounded-full object-cover" alt="Lambda Durable Functions" />
      </div>
      <span>Lambda Durable Functions</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2 opacity-20">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #171717;">
        <img src="/logos/inngest.png" class="h-14 w-14 rounded-full object-cover" alt="Inngest" />
      </div>
      <span>Inngest</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2 opacity-20">
      <div class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center" style="background-color: #1E2533;">
        <img src="/logos/dbos.png" class="h-14 w-14 rounded-full object-cover" alt="DBOS" />
      </div>
      <span>DBOS</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2 text-blue-400 font-bold">
      <div class="h-20 w-20 rounded-full border-2 border-blue-400 flex items-center justify-center overflow-hidden" style="background-color: #ffffff; box-shadow: 0 0 20px 6px rgba(96, 165, 250, 0.6);">
        <img src="/logos/restate.png" class="h-14 w-14 object-cover" alt="Restate" />
      </div>
      <span>Restate</span>
    </div>
    <div class="p-4 flex flex-col items-center gap-2 opacity-20">
      <span class="h-20 w-20 rounded-full border-2 border-gray-500 flex items-center justify-center text-2xl">+</span>
      <span>and others...</span>
    </div>
  </div>
</div>

<style>
  .slidev-vclick-target { transition: all 0.7s ease; }
</style>

---

# Meet Restate

A lightweight runtime for durable execution

<v-clicks>

- **Durable async/await** — write normal code, get automatic resilience
- **Journaling** — every side effect is recorded and replayed on retry
- **Virtual objects** — stateful entities with built-in K/V state
- **Workflows** — long-running operations with signals and timers

</v-clicks>

---

# Demo: Greeter Service

```ts {all|3|4-5|6|7-8|all}
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

<v-click>

What happens when `sendReminder` fails?

</v-click>

---

# Demo: Live

<v-clicks>

Register the service with Restate:

```bash
restate deployments register http://localhost:9080
```

Invoke the greeter (happy path):

```bash
http POST localhost:8080/Greeter/greet name=DevNexus
```

Invoke with failure simulation:

```bash
http POST localhost:8080/Greeter/greet name=Alice
```

</v-clicks>

<!--
**Setup:** run `./scripts/demo.sh` before talk

**Restate UI walkthrough:**

1. Open http://localhost:9070/
2. After registering, show the **Services** tab — Greeter service appears
3. After invoking DevNexus, show **Invocations** — completed successfully
4. After invoking Alice, show **Invocations** — watch retries in real-time
5. Click into the Alice invocation to show journal entries and retry attempts
-->

---
clicks: 7
---

# Durable Execution in Action

<SequenceStepper
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
    { from: 'handler', to: 'handler', label: 'sendNotification() 💾', type: 'self' },
    { from: 'handler', to: 'handler', label: 'ctx.sleep(1s) 💾', type: 'self' },
    { from: 'handler', to: 'handler', label: 'sendReminder() 💾', type: 'self' },
    { from: 'handler', to: 'client', label: '200 OK', type: 'response' },
  ]"
/>

<div class="mt-8 text-sm text-gray-400">
  Press → or Space to step through the execution
</div>

---

# The Execution Flow

<v-clicks>

**1. Request** → `POST /Greeter/greet` starts invocation

**2. UUID** → `ctx.rand.uuidv4()` persisted 💾 → `uuid-1234` (deterministic)

**3. Notification** → `ctx.run("Notification")` executed & journaled 💾

**4. Sleep** → `ctx.sleep(1s)` persisted 💾 → timer scheduled

**5. Reminder** → `ctx.run("Reminder")` executed & journaled 💾

**6. Return** → Result persisted 💾 → `200 OK` to client

</v-clicks>

<v-click>

**Every step durably persisted before proceeding!**

</v-click>

---

# Inside the Journal

Every invocation gets its own append-only journal

<v-clicks>

| # | Entry Type | Name | Result |
|---|-----------|------|--------|
| 0 | **Input** | | `{ name: "DevNexus" }` |
| 1 | **Run** | `uuidv4` | `"a1b2c3d4-..."` |
| 2 | **Run** | `Notification` | `void` |
| 3 | **Sleep** | | `1000ms` |
| 4 | **Run** | `Reminder` | *pending...* |

</v-clicks>

<v-click>

On retry, entries 0-3 are **replayed from the journal** — no re-execution. Only entry 4 runs again.

</v-click>

<v-click>

```bash
restate sql "SELECT * FROM sys_journal WHERE id = '<invocation_id>';"
```

</v-click>

---

# Demo: Inspecting the Journal

<v-clicks>

List invocations to get an ID:

```bash
restate invocations list
```

Describe a specific invocation:

```bash
restate invocations describe <invocation_id>
```

Query the journal directly:

```bash
restate sql "SELECT index, entry_type, name FROM sys_journal WHERE id = '<invocation_id>';"
```

</v-clicks>

<!--
**Restate UI walkthrough:**

1. Open http://localhost:9070/
2. Click **Invocations** — show the list of completed/in-progress invocations
3. Click into the Alice invocation (the one with retries)
4. Show the journal entries — each step with entry type, name, and result
5. Point out the retry attempts on the failed steps
-->

---

# Why This Matters

Durable execution makes resilient apps **accessible to you**

<v-clicks>

- Simplifies microservice orchestration
- Tames long-running operations
- Eliminates retry/state/recovery boilerplate
- You write business logic, not plumbing

</v-clicks>

---
layout: center
---

# Thank You

[@samdengler](https://twitter.com/samdengler)
