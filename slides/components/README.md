# Slidev Sequence Diagram Stepper

An interactive sequence diagram component for [Slidev](https://sli.dev) presentations.
Each press of → / Space / click reveals the next step in the sequence.

## Quick Start

### 1. Create a Slidev project (if you don't have one)

```bash
npm init slidev@latest
```

### 2. Add the component

Copy `components/SequenceStepper.vue` into your Slidev project's `components/` directory:

```
your-slidev-project/
├── components/
│   └── SequenceStepper.vue   ← put it here
├── slides.md
└── package.json
```

Slidev auto-registers any `.vue` file in `components/`, so there's no import needed.

### 3. Use it in your slides

```md
---
clicks: 5
---

# My Sequence Diagram

<SequenceStepper
  :actors="[
    { id: 'a', label: 'Service A' },
    { id: 'b', label: 'Service B' },
    { id: 'c', label: 'Service C' },
  ]"
  :steps="[
    { from: 'a', to: 'b', label: 'request()',  type: 'request'  },
    { from: 'b', to: 'c', label: 'query()',     type: 'request'  },
    { from: 'c', to: 'b', label: 'result',      type: 'response' },
    { from: 'b', to: 'b', label: 'transform()', type: 'self'     },
    { from: 'b', to: 'a', label: '200 OK',      type: 'response' },
  ]"
/>
```

> **Important:** Set `clicks: N` in the slide's frontmatter where N = the number
> of steps. This tells Slidev how many clicks to consume before advancing to the
> next slide.

### 4. Run your presentation

```bash
npm run dev
```

## Step Types

| Type       | Visual                    | Use for                    |
| ---------- | ------------------------- | -------------------------- |
| `request`  | Solid blue arrow →        | Outgoing calls / requests  |
| `response` | Dashed purple arrow ←     | Return values / responses  |
| `self`     | Gold loop on same actor   | Internal processing        |

## Customizing Colors

Pass a `theme` prop to override any color:

```html
<SequenceStepper
  :actors="[...]"
  :steps="[...]"
  :theme="{
    bg: '#1a1a2e',
    request: '#00d2ff',
    response: '#ff6b9d',
    self: '#c3e956',
    actorText: '#ffffff',
    actorBg: '#16213e',
    actorBorder: '#0f3460',
  }"
/>
```

Available color keys: `bg`, `lifeline`, `actorBg`, `actorBorder`, `actorText`,
`request`, `response`, `self`, `stepNum`.

## Tips

- The **latest step glows** so the audience knows what just appeared
- Previous steps fade to ~55% opacity for context
- Going **backward** (← / Backspace) hides steps in reverse
- Works with Slidev's presenter mode — the diagram stays in sync
- You can use multiple SequenceStepper components across different slides
