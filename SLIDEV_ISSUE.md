# Slidev Integration Issue - Help Needed

## Problem Summary

I have a Vue 3 sequence diagram component that works perfectly in standalone HTML, but when integrated into Slidev presentation slides, it renders incorrectly with:

1. **Fonts appear too large** - despite setting small font sizes and using CSS transform scale
2. **Diagram doesn't maximize width** - it's cramped horizontally instead of spreading out
3. **Brief flash then resize** - diagram appears wider for a moment then shrinks

## What Works

✅ **Standalone HTML version** - Component renders perfectly with proper sizing
✅ **Click navigation** - Slidev's $clicks integration works correctly
✅ **Component logic** - All the SVG rendering, animations, etc. work fine

## What Doesn't Work

❌ **Final rendered size in Slidev** - Everything appears too large
❌ **Horizontal spread** - Diagram should use maximum available width but doesn't
❌ **CSS transform scale** - Seems to not apply correctly or conflicts with Slidev

## Files

### 1. Component: `slides/components/MinimalSequence.vue`

```vue
<script setup>
import { computed, onMounted, onUnmounted } from 'vue'
import { useSlideContext } from '@slidev/client'

const props = defineProps({
  actors: { type: Array, required: true },
  steps: { type: Array, required: true },
  scale: { type: Number, default: 0.22 }, // Tiny final size
})

// ── Slidev integration ─────────────────────────────────────
const { $clicks, $clicksContext } = useSlideContext()

const registrationId = `minimal-seq-${Math.random().toString(36).slice(2)}`
onMounted(() => {
  if ($clicksContext) {
    $clicksContext.register(registrationId, { max: props.steps.length })
  }
})
onUnmounted(() => {
  if ($clicksContext) {
    $clicksContext.unregister(registrationId)
  }
})

const visibleSteps = computed(() => Math.min($clicks.value, props.steps.length))

// ── Layout constants ────────────────────────────────────────
const ACTOR_WIDTH = 140
const ACTOR_GAP = 800  // Maximum horizontal spread
const HEADER_HEIGHT = 100
const STEP_HEIGHT = 90
const PADDING = 40

// ── Colors ──────────────────────────────────────────────────
const colors = {
  bg: '#0a0e17',
  lifeline: '#334155',
  actorBg: '#1e293b',
  actorBorder: '#475569',
  actorText: '#e2e8f0',
  request: '#38bdf8',
  response: '#a78bfa',
}

// ── Layout calculations ─────────────────────────────────────
const actorIndexMap = computed(() => {
  const map = {}
  props.actors.forEach((a, i) => (map[a.id] = i))
  return map
})

const svgWidth = computed(() => {
  const lastActorX = getActorX(props.actors.length - 1)
  return lastActorX + ACTOR_WIDTH / 2 + PADDING
})

const svgHeight = computed(() => {
  return HEADER_HEIGHT + props.steps.length * STEP_HEIGHT + 60
})

function getActorX(index) {
  return PADDING + ACTOR_WIDTH / 2 + index * ACTOR_GAP
}

function getStepY(index) {
  return HEADER_HEIGHT + 30 + index * STEP_HEIGHT
}

const renderedSteps = computed(() =>
  props.steps.map((step, i) => {
    const fromIdx = actorIndexMap.value[step.from]
    const toIdx = actorIndexMap.value[step.to]
    const x1 = getActorX(fromIdx)
    const x2 = getActorX(toIdx)
    const y = getStepY(i)
    const midX = (x1 + x2) / 2
    const color = step.type === 'response' ? colors.response : colors.request
    const isDashed = step.type === 'response'
    const isVisible = i < visibleSteps.value

    const direction = x2 > x1 ? 'right' : 'left'
    const arrowSize = 8
    const dx = direction === 'right' ? -arrowSize : arrowSize
    const arrowPoints = `${x2},${y} ${x2 + dx},${y - 4} ${x2 + dx},${y + 4}`

    return {
      ...step,
      index: i,
      x1, x2, y, midX, color, isDashed, isVisible, arrowPoints
    }
  })
)
</script>

<template>
  <div class="minimal-sequence" :style="{ transform: `scale(${scale})` }">
    <svg
      :viewBox="`0 0 ${svgWidth} ${svgHeight}`"
      :width="svgWidth"
      style="max-width: 100%; display: block; margin: 0 auto;"
    >
      <rect :width="svgWidth" :height="svgHeight" :fill="colors.bg" />

      <!-- Lifelines -->
      <line
        v-for="(actor, i) in actors"
        :key="`line-${i}`"
        :x1="getActorX(i)"
        :y1="HEADER_HEIGHT"
        :x2="getActorX(i)"
        :y2="svgHeight - 40"
        :stroke="colors.lifeline"
        stroke-width="2"
        stroke-dasharray="4 4"
      />

      <!-- Actors -->
      <g v-for="(actor, i) in actors" :key="`actor-${i}`">
        <rect
          :x="getActorX(i) - ACTOR_WIDTH / 2"
          :y="20"
          :width="ACTOR_WIDTH"
          :height="40"
          :rx="6"
          :fill="colors.actorBg"
          :stroke="colors.actorBorder"
          stroke-width="2"
        />
        <text
          :x="getActorX(i)"
          :y="50"
          text-anchor="middle"
          :fill="colors.actorText"
          font-size="18"
          font-weight="700"
        >
          {{ actor.label }}
        </text>
      </g>

      <!-- Steps -->
      <g v-for="s in renderedSteps" :key="`step-${s.index}`" v-show="s.isVisible">
        <line
          :x1="s.x1"
          :y1="s.y"
          :x2="s.x2"
          :y2="s.y"
          :stroke="s.color"
          stroke-width="2"
          :stroke-dasharray="s.isDashed ? '6 3' : undefined"
        />
        <polygon :points="s.arrowPoints" :fill="s.color" />
        <text
          :x="s.midX"
          :y="s.y - 10"
          text-anchor="middle"
          :fill="s.color"
          font-size="16"
          font-weight="500"
        >
          {{ s.label }}
        </text>
      </g>
    </svg>

    <div style="text-align: center; margin-top: 12px; color: #64748b; font-size: 14px;">
      {{ visibleSteps }} / {{ steps.length }}
    </div>
  </div>
</template>

<style scoped>
.minimal-sequence {
  width: 100%;
  transform-origin: top center;
}
</style>
```

### 2. Slide: `slides/test-minimal.md`

```md
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

Default scale: 0.22 (tiny text, max width). Adjust scale prop if needed.

---

# End
```

## Expected Behavior

1. **Small text** - Actor labels "A" and "B" should be tiny (~4px final size)
2. **Wide diagram** - Should spread horizontally to use available slide width
3. **Proper scale** - CSS `transform: scale(0.22)` should make everything proportionally smaller

## Actual Behavior

1. **Large text** - Fonts appear much larger than expected
2. **Narrow diagram** - Doesn't spread out horizontally
3. **Flash/resize** - Brief flash of correct size then shrinks

## Strategy Attempted

- **Large SVG viewBox** (800px gap between actors, 18px fonts)
- **Small CSS scale** (0.22 = 22%)
- **Theory**: Big canvas → scale down = tiny but proportional

This works in standalone HTML but not in Slidev!

## Questions for Troubleshooting

1. Does Slidev apply its own scaling/zoom that conflicts with CSS transform?
2. Should we use a different approach for sizing in Slidev?
3. Is there a Slidev-specific way to control component rendering size?
4. Could `preserveAspectRatio` or SVG attributes be the issue?

## Environment

- Slidev: Latest version
- Vue: 3.x
- Node: Latest LTS
- OS: macOS

## Additional Context

The component auto-registers with Slidev's click system using `useSlideContext()` and `$clicksContext.register()`, which works perfectly. The issue is purely visual/sizing.
