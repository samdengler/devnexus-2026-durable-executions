---
theme: default
title: Minimal Sequence Test
---

# Minimal Sequence Test

Simple 2-actor, 2-step diagram

---
clicks: 2
---

# Test: Simplest Diagram

<MinimalSequence
  :actors="[
    { id: 'a', label: 'A' },
    { id: 'b', label: 'B' },
  ]"
  :steps="[
    { from: 'a', to: 'b', label: 'request', type: 'request' },
    { from: 'b', to: 'a', label: 'response', type: 'response' },
  ]"
/>

---

# End
