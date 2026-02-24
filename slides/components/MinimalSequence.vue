<script setup>
/**
 * MinimalSequence — SVG sequence diagram for Slidev with:
 *   - Click-through via useSlideContext $clicks
 *   - Auto-sized actor boxes (getBBox with char-width fallback)
 *   - Self-loops (from===to or type:'self'), yellow #fbbf24
 *   - Smart spacing: sum(widths) + equal gaps in remaining space
 *
 * Slide frontmatter needs `clicks: N` to enable stepping.
 */
import { ref, computed, onMounted, nextTick } from 'vue'
import { useSlideContext } from '@slidev/client'

const props = defineProps({
  actors: { type: Array, required: true },
  steps: { type: Array, required: true },
})

// --- Slidev click integration ---
const { $clicks } = useSlideContext()
const clicks = computed(() => $clicks?.value ?? props.steps.length)
const visibleSteps = computed(() => Math.min(clicks.value, props.steps.length))

// --- Layout constants ---
const SLIDE_W = 980
const SLIDE_H = 400
const HEADER_Y = 30
const STEP_H = 32
const PAD_L = 40
const PAD_R = 200   // extra room for self-loop labels to the right
const BOX_PAD_X = 16
const MIN_BOX_W = 50
const BOX_H = 36
const CHAR_W = 7     // fallback px per char at font-size 11
const FONT_SIZE = 11
const ARROW_FONT_SIZE = FONT_SIZE
const SELF_FONT_SIZE = FONT_SIZE

// --- Auto-sized actor boxes ---
const actorTextRefs = ref([])
const actorWidths = ref([])
const measured = ref(false)

function estimateWidth(label) {
  return Math.max(MIN_BOX_W, label.length * CHAR_W + BOX_PAD_X * 2)
}

onMounted(async () => {
  await nextTick()
  const widths = []
  for (let i = 0; i < props.actors.length; i++) {
    const el = actorTextRefs.value[i]
    if (el) {
      try {
        const bbox = el.getBBox()
        widths.push(Math.max(MIN_BOX_W, bbox.width + BOX_PAD_X * 2))
      } catch {
        widths.push(estimateWidth(props.actors[i].label))
      }
    } else {
      widths.push(estimateWidth(props.actors[i].label))
    }
  }
  actorWidths.value = widths
  measured.value = true
})

// Use estimated widths until measured
const boxWidths = computed(() => {
  if (measured.value && actorWidths.value.length === props.actors.length) {
    return actorWidths.value
  }
  return props.actors.map(a => estimateWidth(a.label))
})

// --- Smart spacing: equal gaps between variable-width boxes ---
const actorPositions = computed(() => {
  const widths = boxWidths.value
  const totalBoxWidth = widths.reduce((s, w) => s + w, 0)
  const n = props.actors.length
  const availableSpace = SLIDE_W - PAD_L - PAD_R - totalBoxWidth
  const gap = n > 1 ? availableSpace / (n - 1) : 0

  const positions = []
  let x = PAD_L
  for (let i = 0; i < n; i++) {
    const cx = x + widths[i] / 2
    positions.push({ cx, w: widths[i] })
    x += widths[i] + gap
  }
  return positions
})

const svgH = computed(() => Math.min(SLIDE_H, HEADER_Y + BOX_H + 20 + props.steps.length * STEP_H + 40))

const actorIdx = computed(() => {
  const m = {}
  props.actors.forEach((a, i) => m[a.id] = i)
  return m
})

const ax = (i) => actorPositions.value[i]?.cx ?? 0
const sy = (i) => HEADER_Y + BOX_H + 20 + i * STEP_H

// --- Step color helper ---
function stepColor(s) {
  if (s.type === 'self' || s.from === s.to) return '#fbbf24'
  if (s.type === 'response') return '#a78bfa'
  return '#38bdf8'
}

// --- Rendered steps ---
const rendered = computed(() =>
  props.steps.map((s, i) => {
    const fromIdx = actorIdx.value[s.from]
    const toIdx = actorIdx.value[s.to]
    const isSelf = s.type === 'self' || s.from === s.to
    const x1 = ax(fromIdx)
    const x2 = ax(toIdx)
    const y = sy(i)
    const color = stepColor(s)

    if (isSelf) {
      // Self-loop: small arc to the right of the lifeline
      const loopW = 18
      const loopH = 16
      return {
        ...s, y, color, isSelf: true,
        vis: i < visibleSteps.value,
        // Path: go right, arc down, come back left
        path: `M ${x1},${y - loopH/2} L ${x1 + loopW},${y - loopH/2} L ${x1 + loopW},${y + loopH/2} L ${x1},${y + loopH/2}`,
        arrowX: x1,
        arrowY: y + loopH / 2,
        labelX: x1 + loopW + 4,
        labelY: y,
      }
    }

    const mid = (x1 + x2) / 2
    const dx = x2 > x1 ? -6 : 6
    return {
      ...s, x1, x2, y, mid, color, isSelf: false,
      dash: s.type === 'response',
      vis: i < visibleSteps.value,
      arrow: `${x2},${y} ${x2+dx},${y-3} ${x2+dx},${y+3}`,
    }
  })
)
</script>

<template>
  <svg :viewBox="`0 0 ${SLIDE_W} ${svgH}`" class="min-seq"
       preserveAspectRatio="xMidYMid meet">
    <!-- lifelines -->
    <line v-for="(_, i) in actors" :key="'l'+i"
      :x1="ax(i)" :y1="HEADER_Y + BOX_H + 2" :x2="ax(i)" :y2="svgH - 5"
      stroke="#475569" stroke-width="0.5" stroke-dasharray="2 2" />

    <!-- actor boxes (auto-sized) -->
    <g v-for="(a, i) in actors" :key="'a'+i">
      <rect
        :x="ax(i) - boxWidths[i] / 2"
        :y="HEADER_Y"
        :width="boxWidths[i]"
        :height="BOX_H"
        rx="3"
        fill="#1e293b" stroke="#334155" stroke-width="0.5" />
      <text
        :ref="el => { actorTextRefs[i] = el }"
        :x="ax(i)"
        :y="HEADER_Y + BOX_H / 2"
        text-anchor="middle"
        dominant-baseline="central"
        fill="#e2e8f0"
        :font-size="FONT_SIZE"
        font-weight="600"
        font-family="system-ui, sans-serif">
        {{ a.label }}
      </text>
    </g>

    <!-- steps -->
    <template v-for="(s, i) in rendered" :key="'s'+i">
      <g v-if="s.vis">
        <!-- self-loop -->
        <template v-if="s.isSelf">
          <path :d="s.path" fill="none" :stroke="s.color" stroke-width="1.5" />
          <polygon
            :points="`${s.arrowX},${s.arrowY} ${s.arrowX+6},${s.arrowY-3} ${s.arrowX+6},${s.arrowY+3}`"
            :fill="s.color" />
          <text :x="s.labelX" :y="s.labelY"
            text-anchor="start" dominant-baseline="central"
            :fill="s.color"
            :font-size="SELF_FONT_SIZE" font-weight="500" font-family="system-ui, sans-serif">
            {{ s.label }}
          </text>
        </template>

        <!-- normal arrow -->
        <template v-else>
          <line :x1="s.x1" :y1="s.y" :x2="s.x2" :y2="s.y"
            :stroke="s.color" stroke-width="1.5"
            :stroke-dasharray="s.dash ? '6 3' : undefined" />
          <polygon :points="s.arrow" :fill="s.color" />
          <text :x="s.mid" :y="s.y - 5" text-anchor="middle"
            :fill="s.color"
            :font-size="ARROW_FONT_SIZE" font-weight="500" font-family="system-ui, sans-serif">
            {{ s.label }}
          </text>
        </template>
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
