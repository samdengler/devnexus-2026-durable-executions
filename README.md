# Durable Execution: Building Apps That Refuse to Die

**DevNexus 2026** | Sam Dengler

Building distributed applications is hard, with challenges like retries, state management, and failure recovery often adding hidden complexity. Durable execution frameworks address these problems by persisting execution and resuming seamlessly after crashes, so developers can focus on business logic instead of plumbing. In this session, you'll see practical code examples and a live demo of how durable execution simplifies microservice orchestration and long-running operations, making resilient apps accessible to every developer.

[View the talk on DevNexus](https://devnexus.com/events/durable-execution-building-apps-that-refuse-to-die)

## Slides

The slide deck is built with [Slidev](https://sli.dev/) and located in the `slides/` directory.

```bash
cd slides
npm install
npx slidev --open false
```

Then open http://localhost:3030/

## Demo Services

The `services/` directory contains the Restate durable execution demo services used during the live portion of the talk.
