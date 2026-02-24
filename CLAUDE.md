# Durable Execution Slides — DevNexus 2026

## Project Structure

- `slides/` — Slidev presentation (`slides.md` + components)
- `slides/components/` — Custom Vue components for slides
- `services/` — Restate demo services

## Interactive Sequence Diagrams (InteractiveSequence)

**Component:** `slides/components/InteractiveSequence.vue`

Use `<InteractiveSequence>` for click-through sequence diagrams in Slidev slides.

**Slide frontmatter** — must include `clicks: N` where N = number of steps:
```yaml
---
clicks: 7
---
```

**Usage:**
```html
<InteractiveSequence
  :actors="[
    { id: 'client', label: 'Client' },
    { id: 'server', label: 'Server' },
  ]"
  :steps="[
    { from: 'client', to: 'server', label: 'request', type: 'request' },
    { from: 'server', to: 'server', label: 'process()', type: 'self' },
    { from: 'server', to: 'client', label: '200 OK', type: 'response' },
  ]"
/>
```

**Step types and colors:**
- `type: 'request'` — solid blue line `#38bdf8`
- `type: 'response'` — dashed purple line `#a78bfa`
- `type: 'self'` (or `from === to`) — yellow self-loop `#fbbf24`, label to the right

**Layout rules:**
- Actor boxes auto-size to text width (getBBox + fallback)
- Equal gaps between boxes; extra right padding (200px) for self-loop labels
- All text (boxes, arrows, self-loops) uses same font size (11px in SVG units)
- Line stroke width 1.5, arrowheads 6x6
- No emojis in step labels

## Slidev

- Dev server: `cd slides && npx slidev --open false`
- Build: `cd slides && npx slidev build`
- Entry file: `slides/slides.md` (default, no need to specify)
