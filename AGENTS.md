# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Slidev Sequence Diagram Components

### Key Lessons (SVG in Slidev)

**The scaling problem:** Slidev renders slides at a fixed canvas size (980×551px by default, set via `canvasWidth` and `aspectRatio: 16/9`) and then CSS-transforms the entire slide to fill the browser viewport. SVG content inside slides gets scaled up by this transform, making text and elements appear much larger than their declared sizes.

**The fix:** Design the SVG `viewBox` to match Slidev's canvas width (980px). This makes the viewBox-to-container scale ~1×, so the only remaining scale is Slidev's CSS transform (which also affects regular slide text equally). Use small SVG units:

| Element       | Recommended Size |
|---------------|-----------------|
| Font (actors) | 7               |
| Font (labels) | 4               |
| Stroke width  | 0.5–0.7         |
| Actor box     | 60w × 40h       |
| Step height   | 25              |
| Arrow head    | 3               |

### Vue Component Rules for Slidev

1. **Click integration:** Use `useSlideContext()` from `@slidev/client` — NOT `inject('$slidev')` (wrong key) and NOT declaring `const $slidev` (conflicts with Slidev's auto-injected template variable). Destructure only what you need:
   ```js
   import { useSlideContext } from '@slidev/client'
   const { $clicks } = useSlideContext()
   ```

2. **Click counting:** Set `clicks: N` in slide frontmatter. Access clicks via:
   ```js
   const { $clicks } = useSlideContext()
   const clicks = computed(() => $clicks?.value ?? props.steps.length)
   ```

3. **`v-if` + `v-for` on same element:** Vue 3 evaluates `v-if` before `v-for`, so loop variables aren't accessible. Wrap with `<template v-for>`:
   ```html
   <template v-for="(s, i) in items" :key="i">
     <g v-if="s.visible">...</g>
   </template>
   ```

4. **Running Slidev locally:** Use the local binary, not `npx slidev` (which may use a global cache):
   ```bash
   cd slides && ./node_modules/.bin/slidev test-minimal.md --port 3033 --open false
   ```

### Component Files

- `slides/components/MinimalSequence.vue` — Simplified sequence diagram (SVG, ~100 lines). Used for testing and as the reference implementation.
- `slides/components/SequenceStepper.vue` — Full-featured version with self-loops, step numbers, progress bar, glow effects. Uses `inject('$slidev')` pattern.
- `slides/test-minimal.md` — Test slide deck for MinimalSequence.


