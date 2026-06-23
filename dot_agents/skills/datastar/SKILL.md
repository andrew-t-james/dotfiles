---
name: datastar
description: Build reactive hypermedia web applications with backend-driven UI updates. 10.7KB framework combining HTMX-style backend reactivity with Alpine.js-style frontend reactivity.
---

# DataStar

Build reactive web applications with server-driven updates and declarative HTML attributes.

> **⛔ MANDATORY — NO FABRICATION:** Before writing ANY DataStar code or explaining ANY DataStar attribute/action/event, you MUST consult the bundled `references/` and `modules/` files first. Do NOT generate syntax from memory — it will be wrong.
>
> **Required workflow for every DataStar question:**
> 1. `Grep "<keyword>"` across this skill's `references/` and `modules/` directories to locate the relevant file.
> 2. `Read` that file to get exact syntax.
> 3. Quote it directly.
> 4. If the answer is not in the bundled files, fetch the official docs at https://data-star.dev before answering.
>
> If nothing is found → say "Not found in DataStar references" and stop. **Never invent syntax.**

## Quick Start

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.0/bundles/datastar.js"></script>
```

**Signal naming:** camelCase is the default and recommended convention. Hyphenated HTML attributes auto-convert to camelCase. Use `__case.snake` to opt into snake_case.

## Core Concepts

### Signals (State)
```html
<div data-signals="{count: 0, name: ''}">
    <input data-bind:name />
    <div data-text="$count"></div>
    <div data-computed:doubled="$count * 2" data-text="$doubled"></div>
</div>
```

### Actions (Backend Requests)
```html
<button data-on:click="@get('/data')">Load</button>
<button data-on:click="@post('/save')" data-indicator:saving>Save</button>
```

### Backend Responses (SSE)
```
event: datastar-patch-elements
data: elements <div id="foo">Content</div>

event: datastar-patch-signals
data: signals {count: 5}
```

## Knowledge Modules

| Module | Description |
|--------|-------------|
| `modules/tao.md` | The Tao of Datastar - 14 core principles from the team |
| `modules/gotchas.md` | Critical pitfalls with fixes |
| `modules/core.md` | Architecture, signals, actions |
| `modules/best-practices.md` | Naming, performance, security |
| `modules/debugging.md` | Common errors and solutions |

## Reference Files

| Reference | Description |
|-----------|-------------|
| `references/attributes.md` | All data-* attributes |
| `references/actions.md` | All @ actions |
| `references/patterns.md` | UI patterns (forms, lists, etc.) |
| `references/sse-events.md` | SSE protocol, SDK examples |

## Examples

| Example | Description |
|---------|-------------|
| `examples/realtime-counter.html` | Simplest reactive example |
| `examples/form-validation.html` | Form with client-side validation |
| `examples/dynamic-list.html` | Add/remove items via SSE |
| `examples/todo-app.html` | Complete todo application |
| `examples/wp-sse-endpoint.php` | WordPress SSE handler |

## The Tao of Datastar (Philosophy)

14 official principles from the core team. Key takeaways:
- **Backend is source of truth** - state lives on server, not client
- **Patch, don't poll** - backend drives frontend via SSE patches
- **Signals are sparse** - only for UI toggles + form binding
- **Fat morph** - send large DOM chunks, let morphing handle diffs
- **CQRS** - one long-lived GET for reads, short POSTs for writes
- **No optimistic updates** - never fake success, use loading indicators
- **No client-side routing** - use `<a>` tags and View Transition API

See `modules/tao.md` for all 14 principles with code examples.

## Top 5 Gotchas

1. **camelCase signals** (default) - `playerName` not `player_name` (snake_case opt-in via `__case.snake`)
2. **Server is source of truth** - No localStorage for state
3. **Missing IDs** - Elements need `id=` for morphing
4. **FOUC prevention** - Add `style="display:none"` to data-show
5. **PHP output buffering** - Disable with `ob_end_clean()` for SSE

See `modules/gotchas.md` for the full list.

Block-form statements (`if (…) { … }`, `for { }`, `try { }`) in `data-on-*` / `data-effect`
break the expression parser — half the page works, the rest silently fails to mount.
Use ternary `?:` or delegate to `window.fn()`.

## When to Use DataStar

**Good fit:** Server-rendered apps, real-time dashboards, forms, CRUD apps, multi-step workflows

**Not ideal:** Offline-first apps, heavy client computation, complex routing, gaming

## Official Resources

- **Docs:** https://data-star.dev
- **GitHub:** https://github.com/starfederation/datastar
- **Version:** 1.0.0 (released 2026-04-16)
