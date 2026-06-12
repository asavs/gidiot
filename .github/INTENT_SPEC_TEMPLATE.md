<!--
Intent-spec — written by the intent tier (see AGENTS.md "Agent stack"), handed to the
orchestration tier. Captures WHAT and WHY at engineering altitude. Lazy-point to the
issue for motivation; do not restate it. One intent-spec per dispatched run.
-->

# Intent-spec: <short title>

**Issue:** #<n>   <!-- the single source of intent; this doc points at it, never restates it -->

## Change
<!-- the change to make, in 1-3 sentences at engineering altitude (what, not how) -->

## Constraints & invariants
<!-- hard rules the change must not violate; folder-scoped GUIDELINES that apply -->

## Acceptance checks
<!-- observable conditions that make this done — what QA/CI will verify -->

## Out of scope
<!-- explicitly what NOT to touch, to keep the run branch-sized (smallest change) -->