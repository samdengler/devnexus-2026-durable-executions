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

DevNexus 2026

---
layout: two-cols-header
---

# About Me

<img src="/avatar.png" class="rounded-full w-40 h-40" />

::left::

**Sam Dengler**

Sr Principal Engineer, JPMorganChase

AWS, serverless, event-driven architectures, distributed systems

::right::

@samdengler
<br>[Twitter](https://twitter.com/samdengler) / [LinkedIn](https://linkedin.com/in/samdengler) / [GitHub](https://github.com/samdengler)

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

# Durable Execution in Action

Restate journals each step:

<v-clicks>

1. `ctx.rand.uuidv4()` — deterministic, replays the same value
2. `ctx.run("Notification", ...)` — result stored, never re-executed
3. `ctx.sleep(...)` — durable timer, survives restarts
4. `ctx.run("Reminder", ...)` — retried automatically on failure

</v-clicks>

<v-click>

**No duplicate notifications. No lost state. No boilerplate.**

</v-click>

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
