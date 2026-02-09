---
layout: center
---

# Testing MinimalSequence Component

This slide demonstrates the `MinimalSequence` component with a few actors and steps. You can toggle between light and dark mode using the Slidev UI to check theme-awareness.

<MinimalSequence
  :actors="[
    { id: 'user', label: 'User' },
    { id: 'service', label: 'My Service' },
    { id: 'db', label: 'Database' }
  ]"
  :steps="[
    { from: 'user', to: 'service', label: 'POST /data' },
    { from: 'service', to: 'db', label: 'INSERT', type: 'request' },
    { from: 'db', to: 'service', label: 'OK', type: 'response' },
    { from: 'service', to: 'user', label: '201 Accepted', type: 'response' }
  ]"
/>

---
clicks: 0
---

# Testing Clicks

The component should reveal one step at a time as you click through the slide.

<div v-click-hide>
<p>Click to start revealing the sequence.</p>
</div>

<MinimalSequence
  :actors="[
    { id: 'user', label: 'User' },
    { id: 'service', label: 'My Service' },
    { id: 'db', label: 'Database' }
  ]"
  :steps="[
    { from: 'user', to: 'service', label: 'POST /data' },
    { from: 'service', to: 'db', label: 'INSERT', type: 'request' },
    { from: 'db', to: 'service', label: 'OK', type: 'response' },
    { from: 'service', to: 'user', label: '201 Accepted', type: 'response' }
  ]"
/>
