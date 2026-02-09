<script setup>
/**
 * SequenceStepper.vue — A Slidev-native sequence diagram component.
 *
 * Drop this file into your Slidev project's `components/` directory,
 * then use it in slides.md. Each Slidev click reveals the next step.
 *
 * Props:
 *   actors  — Array of { id, label } objects
 *   steps   — Array of { from, to, label, type } objects
 *              type: 'request' | 'response' | 'self'
 *
 * Usage in slides.md:
 *   ---
 *   clicks: 7        # set to the number of steps
 *   ---
 *   <SequenceStepper :actors="[...]" :steps="[...]" />
 */
import { computed, inject } from 'vue'

const props = defineProps({
  actors: {
    type: Array,
    required: true,
  },
  steps: {
    type: Array,
    required: true,
  },
  // Optional: override colors
  theme: {
    type: Object,
    default: () => ({}),
  },
})

// ── Slidev integration ─────────────────────────────────────────────────
// Access Slidev's reactive click count for the current slide.
// Falls back to showing all steps if used outside Slidev.
// $slidev is automatically injected by Slidev, so we just use inject with a fallback
const slidevContext = inject('$slidev', null)
const clicks = computed(() => {
  if (slidevContext?.nav?.clicks != null) return slidevContext.nav.clicks
  return props.steps.length // fallback: show everything
})

// ── Layout constants ────────────────────────────────────────────────────
const ACTOR_WIDTH = 100
const ACTOR_GAP = 140
const HEADER_HEIGHT = 40
const STEP_HEIGHT = 30
const PADDING_X = 20
const SELF_LOOP_WIDTH = 20

// ── Theme ───────────────────────────────────────────────────────────────
const defaultColors = {
  bg: '#0a0e17',
  lifeline: '#1e293b',
  actorBg: '#0f172a',
  actorBorder: '#334155',
  actorText: '#e2e8f0',
  request: '#38bdf8',
  response: '#a78bfa',
  self: '#fbbf24',
  stepNum: '#0ea5e9',
}

const colors = computed(() => ({ ...defaultColors, ...props.theme }))

// ── Computed layout ─────────────────────────────────────────────────────
const actorIndexMap = computed(() => {
  const map = {}
  props.actors.forEach((a, i) => (map[a.id] = i))
  return map
})

const svgWidth = computed(() => {
  // Calculate width based on actor spacing (not spreading across full width)
  const actorSpacing = (props.actors.length - 1) * ACTOR_GAP
  const baseWidth = PADDING_X + ACTOR_WIDTH / 2 + actorSpacing + ACTOR_WIDTH / 2 + PADDING_X

  // Add extra space for self-loop labels
  const hasSelfLoops = props.steps.some(s => s.type === 'self')
  const selfLoopPadding = hasSelfLoops ? 120 : 0

  return baseWidth + selfLoopPadding
})

const svgHeight = computed(() =>
  HEADER_HEIGHT + props.steps.length * STEP_HEIGHT + 40
)

function getActorX(index) {
  // Fixed spacing based on ACTOR_GAP, not spreading across full SVG width
  const startX = PADDING_X + ACTOR_WIDTH / 2
  return startX + index * ACTOR_GAP
}

function getStepY(index) {
  return HEADER_HEIGHT + 15 + index * STEP_HEIGHT + STEP_HEIGHT / 2
}

function getStepColor(type) {
  if (type === 'response') return colors.value.response
  if (type === 'self') return colors.value.self
  return colors.value.request
}

// ── Per-step computed data ───────────────────────────────────────────────
const renderedSteps = computed(() =>
  props.steps.map((step, i) => {
    const fromIdx = actorIndexMap.value[step.from]
    const toIdx = actorIndexMap.value[step.to]
    const y = getStepY(i)
    const color = getStepColor(step.type)
    const isVisible = i < clicks.value
    const isLatest = i === clicks.value - 1
    const opacity = isLatest ? 1 : 0.55
    const isSelf = step.type === 'self'
    const isDashed = step.type === 'response'

    const x1 = getActorX(fromIdx)
    const x2 = getActorX(toIdx)
    const direction = x2 > x1 ? 'right' : 'left'
    const midX = (x1 + x2) / 2

    // Arrow head points
    const arrowSize = 8
    const dx = direction === 'right' ? -arrowSize : arrowSize
    const arrowPoints = `${x2},${y} ${x2 + dx},${y - arrowSize / 2} ${x2 + dx},${y + arrowSize / 2}`

    // Self-loop geometry
    const loopTop = y - 12
    const loopBot = y + 12
    const loopRight = x1 + SELF_LOOP_WIDTH
    const selfPath = `M ${x1} ${loopTop} H ${loopRight} V ${loopBot} H ${x1}`
    const selfArrowPoints = `${x1},${loopBot} ${x1 + arrowSize},${loopBot - arrowSize / 2} ${x1 + arrowSize},${loopBot + arrowSize / 2}`

    // Label background
    const labelWidth = step.label.length * 8 + 20
    const labelX = isSelf ? loopRight + 6 : midX - labelWidth / 2
    const labelTextX = isSelf ? loopRight + 14 : midX
    const labelTextAnchor = isSelf ? 'start' : 'middle'
    const labelRectY = isSelf ? y - 11 : y - 22
    const labelRectH = isSelf ? 22 : 20
    const labelTextY = isSelf ? y + 4 : y - 9

    // Step number position
    const numX = isSelf ? x1 - 20 : Math.min(x1, x2) - 18

    return {
      ...step,
      index: i,
      y,
      color,
      isVisible,
      isLatest,
      opacity,
      isSelf,
      isDashed,
      x1,
      x2,
      direction,
      midX,
      arrowPoints,
      selfPath,
      selfArrowPoints,
      loopRight,
      labelWidth,
      labelX,
      labelTextX,
      labelTextAnchor,
      labelRectY,
      labelRectH,
      labelTextY,
      numX,
    }
  })
)
</script>

<template>
  <div class="sequence-stepper-wrapper">
    <svg
      :viewBox="`0 0 ${svgWidth} ${svgHeight}`"
      preserveAspectRatio="xMidYMid meet"
      :style="{
        width: '100%',
        height: 'auto',
        display: 'block',
        background: colors.bg
      }"
    >
      <defs>
        <filter id="seq-glow">
          <feGaussianBlur stdDeviation="3" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
        <filter id="seq-softGlow">
          <feGaussianBlur stdDeviation="1.5" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      <!-- Lifelines -->
      <line
        v-for="(actor, i) in actors"
        :key="`lifeline-${actor.id}`"
        :x1="getActorX(i)"
        :y1="HEADER_HEIGHT + 10"
        :x2="getActorX(i)"
        :y2="svgHeight - 20"
        :stroke="colors.lifeline"
        stroke-width="1.5"
        stroke-dasharray="6 4"
      />

      <!-- Actor boxes -->
      <g v-for="(actor, i) in actors" :key="`actor-${actor.id}`">
        <rect
          :x="getActorX(i) - ACTOR_WIDTH / 2"
          :y="12"
          :width="ACTOR_WIDTH"
          :height="30"
          :rx="4"
          :fill="colors.actorBg"
          :stroke="colors.actorBorder"
          stroke-width="1"
        />
        <text
          :x="getActorX(i)"
          :y="30"
          text-anchor="middle"
          :fill="colors.actorText"
          font-size="9"
          font-weight="600"
          font-family="'JetBrains Mono', 'Fira Code', 'SF Mono', monospace"
        >
          {{ actor.label }}
        </text>
      </g>

      <!-- Steps -->
      <g
        v-for="s in renderedSteps"
        :key="`step-${s.index}`"
        v-show="s.isVisible"
        :opacity="s.opacity"
        :style="{
          transition: 'opacity 0.3s ease',
        }"
      >
        <!-- Self-loop -->
        <template v-if="s.isSelf">
          <path
            :d="s.selfPath"
            fill="none"
            :stroke="s.color"
            stroke-width="2"
            :filter="s.isLatest ? 'url(#seq-glow)' : undefined"
          />
          <polygon :points="s.selfArrowPoints" :fill="s.color" />
        </template>

        <!-- Normal arrow -->
        <template v-else>
          <line
            :x1="s.x1"
            :y1="s.y"
            :x2="s.x2 + (s.direction === 'right' ? -1 : 1)"
            :y2="s.y"
            :stroke="s.color"
            stroke-width="2"
            :stroke-dasharray="s.isDashed ? '8 4' : undefined"
            :filter="s.isLatest ? 'url(#seq-glow)' : undefined"
          />
          <polygon :points="s.arrowPoints" :fill="s.color" />
        </template>

        <!-- Label background -->
        <rect
          :x="s.labelX"
          :y="s.labelRectY"
          :width="s.labelWidth"
          :height="s.labelRectH"
          rx="4"
          :fill="colors.bg"
          fill-opacity="0.9"
        />

        <!-- Label text -->
        <text
          :x="s.labelTextX"
          :y="s.labelTextY"
          :text-anchor="s.labelTextAnchor"
          :fill="s.color"
          font-size="8"
          font-family="'JetBrains Mono', 'Fira Code', monospace"
          font-weight="500"
          :filter="s.isLatest ? 'url(#seq-softGlow)' : undefined"
        >
          {{ s.label }}
        </text>

        <!-- Step number -->
        <text
          :x="s.numX"
          :y="s.y + 3"
          :fill="colors.stepNum"
          font-size="7"
          font-family="'JetBrains Mono', monospace"
          font-weight="700"
          text-anchor="end"
          opacity="0.7"
        >
          {{ s.index + 1 }}
        </text>
      </g>
    </svg>

    <!-- Progress indicator -->
    <div class="seq-progress">
      <div
        class="seq-progress-bar"
        :style="{
          width: `${steps.length > 0 ? (Math.min(clicks, steps.length) / steps.length) * 100 : 0}%`,
        }"
      />
    </div>
    <div class="seq-counter">
      {{ Math.min(clicks, steps.length) }} / {{ steps.length }}
    </div>
  </div>
</template>

<style scoped>
.sequence-stepper-wrapper {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.seq-progress {
  width: 80%;
  max-width: 600px;
  height: 2px;
  background: #1e293b;
  border-radius: 1px;
  margin-top: 12px;
  overflow: hidden;
}
.seq-progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #38bdf8, #a78bfa);
  transition: width 0.3s ease;
}
.seq-counter {
  margin-top: 6px;
  font-size: 12px;
  color: #64748b;
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
}
</style>
