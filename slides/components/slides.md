---
theme: default
title: Sequence Diagram Stepper Demo
background: '#0a0e17'
class: text-center
highlighter: shiki
drawings:
  persist: false
---

# Sequence Diagram Stepper

Press **→** or **Space** to reveal each step

<style>
  h1 { color: #e2e8f0 !important; }
  p  { color: #94a3b8 !important; }
</style>

---
clicks: 7
background: '#0a0e17'
---

# Login Flow

<SequenceStepper
  :actors="[
    { id: 'client',  label: 'Client' },
    { id: 'gateway', label: 'API Gateway' },
    { id: 'auth',    label: 'Auth Service' },
    { id: 'db',      label: 'Database' },
  ]"
  :steps="[
    { from: 'client',  to: 'gateway', label: 'POST /login',         type: 'request'  },
    { from: 'gateway', to: 'auth',    label: 'validateCredentials()', type: 'request'  },
    { from: 'auth',    to: 'db',      label: 'SELECT user WHERE …',  type: 'request'  },
    { from: 'db',      to: 'auth',    label: 'User record',          type: 'response' },
    { from: 'auth',    to: 'auth',    label: 'Generate JWT',         type: 'self'     },
    { from: 'auth',    to: 'gateway', label: '{ token, expiry }',    type: 'response' },
    { from: 'gateway', to: 'client',  label: '200 OK + token',       type: 'response' },
  ]"
/>

<style>
  h1 { color: #e2e8f0 !important; font-family: 'JetBrains Mono', monospace; }
</style>

---
clicks: 5
background: '#0a0e17'
---

# Order Processing

<SequenceStepper
  :actors="[
    { id: 'user',    label: 'User' },
    { id: 'api',     label: 'Order API' },
    { id: 'payment', label: 'Payment' },
    { id: 'notify',  label: 'Notifications' },
  ]"
  :steps="[
    { from: 'user',    to: 'api',     label: 'placeOrder()',     type: 'request'  },
    { from: 'api',     to: 'payment', label: 'chargeCard()',     type: 'request'  },
    { from: 'payment', to: 'api',     label: 'paymentConfirmed', type: 'response' },
    { from: 'api',     to: 'notify',  label: 'sendReceipt()',    type: 'request'  },
    { from: 'api',     to: 'user',    label: '201 Created',      type: 'response' },
  ]"
/>

<style>
  h1 { color: #e2e8f0 !important; font-family: 'JetBrains Mono', monospace; }
</style>

---
background: '#0a0e17'
---

# How It Works

<div class="text-left mx-auto max-w-lg space-y-4 mt-8" style="color: #94a3b8; font-family: 'JetBrains Mono', monospace; font-size: 14px;">

<v-clicks>

**1.** Drop `SequenceStepper.vue` into your `components/` directory

**2.** Set `clicks: N` in your slide's frontmatter (N = number of steps)

**3.** Pass `actors` and `steps` as props — that's it!

**4.** Slidev's built-in navigation (→, Space, click) reveals each step

**5.** Going backwards (←, Backspace) hides steps in reverse

</v-clicks>

</div>

<style>
  h1 { color: #e2e8f0 !important; font-family: 'JetBrains Mono', monospace; }
</style>
