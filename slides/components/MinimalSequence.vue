<script setup>
/**
 * MinimalSequence — dead-simple SVG sequence diagram for Slidev.
 * Uses inject('$slidev') for click count. No registration needed
 * when the slide's frontmatter has `clicks: N`.
 */
import { computed } from 'vue'
import { useSlideContext } from '@slidev/client'

const props = defineProps({
  actors: { type: Array, required: true },
  steps: { type: Array, required: true },
})

// --- Slidev click integration ---
// $clicks is a ref to the current click count for this slide
const { $clicks } = useSlideContext()
const clicks = computed(() => $clicks?.value ?? props.steps.length)
const visibleSteps = computed(() => Math.min(clicks.value, props.steps.length))

// --- Layout (matches Slidev's 980×551 canvas) ---
const SLIDE_W = 980
const SLIDE_H = 400  // leave room for slide title
const ACTOR_W = 60
const HEADER_Y = 20
const STEP_H = 25
const PAD = 40

// Spread actors evenly across the slide width
const gap = computed(() => {
  if (props.actors.length <= 1) return 0
  return (SLIDE_W - PAD * 2 - ACTOR_W) / (props.actors.length - 1)
})

const svgH = computed(() => Math.min(SLIDE_H, HEADER_Y + 40 + props.steps.length * STEP_H + 40))

const actorIdx = computed(() => {
  const m = {}
  props.actors.forEach((a, i) => m[a.id] = i)
  return m
})

const ax = (i) => PAD + ACTOR_W / 2 + i * gap.value
const sy = (i) => HEADER_Y + 60 + i * STEP_H

const rendered = computed(() =>
  props.steps.map((s, i) => {
    const x1 = ax(actorIdx.value[s.from])
    const x2 = ax(actorIdx.value[s.to])
    const y = sy(i)
    const mid = (x1 + x2) / 2
    const dx = x2 > x1 ? -3 : 3
    return {
      ...s, x1, x2, y, mid,
      dash: s.type === 'response',
      vis: i < visibleSteps.value,
      arrow: `${x2},${y} ${x2+dx},${y-1.5} ${x2+dx},${y+1.5}`,
    }
  })
)
</script>

<template>
  <svg :viewBox="`0 0 ${SLIDE_W} ${svgH}`" class="min-seq"
       preserveAspectRatio="xMidYMid meet">
    <!-- lifelines -->
    <line v-for="(a, i) in actors" :key="'l'+i"
      :x1="ax(i)" :y1="HEADER_Y + 8" :x2="ax(i)" :y2="svgH - 5"
      stroke="#475569" stroke-width="0.5" stroke-dasharray="2 2" />

    <!-- actor boxes -->
    <g v-for="(a, i) in actors" :key="'a'+i">
      <rect :x="ax(i) - ACTOR_W/2" :y="HEADER_Y - 20" :width="ACTOR_W" height="40" rx="3"
        fill="#1e293b" stroke="#334155" stroke-width="0.5" />
      <text :x="ax(i)" :y="HEADER_Y" text-anchor="middle" dominant-baseline="central"
        fill="#e2e8f0" font-size="7" font-weight="600" font-family="system-ui, sans-serif">
        {{ a.label }}
      </text>
    </g>

    <!-- steps -->
    <template v-for="(s, i) in rendered" :key="'s'+i">
      <g v-if="s.vis">
        <line :x1="s.x1" :y1="s.y" :x2="s.x2" :y2="s.y"
          :stroke="s.type === 'response' ? '#a78bfa' : '#38bdf8'" stroke-width="0.7"
          :stroke-dasharray="s.dash ? '6 3' : undefined" />
        <polygon :points="s.arrow"
          :fill="s.type === 'response' ? '#a78bfa' : '#38bdf8'" />
        <text :x="s.mid" :y="s.y - 4" text-anchor="middle"
          :fill="s.type === 'response' ? '#a78bfa' : '#38bdf8'"
          font-size="4" font-weight="500" font-family="system-ui, sans-serif">
          {{ s.label }}
        </text>
      </g>
    </template>
  </svg>
</template>

<style scoped>
.min-seq {
  width: 100%;
  max-height: 70vh;
  display: block;
}
</style>