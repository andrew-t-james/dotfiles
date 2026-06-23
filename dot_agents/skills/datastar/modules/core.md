# DataStar Core Architecture

## Overview

DataStar is a hypermedia framework for creating reactive frontends driven by backend logic:

- **Backend-driven**: Server sends HTML, JSON, or SSE to update DOM/state
- **Frontend reactivity**: Signals (reactive variables) with `$` prefix
- **Declarative**: Use `data-*` attributes instead of JavaScript
- **Lightweight**: Single 10.7KB script, no build step

## Installation

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.0/bundles/datastar.js"></script>
```

**Important:**
- Use correct version format: `datastar@v1.0.0` (not `[email protected]`)
- Auto-initializes on DOM load - no manual setup needed
- **Signal naming**: camelCase is the default and recommended convention. Hyphenated HTML attributes auto-convert to camelCase. Use `__case.snake` modifier to opt into snake_case if needed.

## 1. Signals (State)

Reactive variables prefixed with `$`:

```html
<div data-signals="{count: 0, name: 'John'}">
    <!-- Two-way binding -->
    <input data-bind:name />

    <!-- Display signals -->
    <div data-text="$count"></div>

    <!-- Expressions -->
    <div data-text="$name.toUpperCase()"></div>

    <!-- Computed signals -->
    <div data-computed:doubled="$count * 2"
         data-text="$doubled"></div>
</div>
```

**Nested signals:**
```html
<div data-signals="{user: {name: '', email: ''}}">
    <input data-bind:user.name />
    <input data-bind:user.email />
</div>
```

## CRITICAL: data-signals Scope Requirement

DataStar ONLY processes elements that are descendants of (or themselves have) a `data-signals` attribute. Without it, `data-init`, `data-on:*`, `data-bind:*` etc. are **silently ignored**.

```html
<!-- BROKEN: no data-signals ancestor, data-init is ignored -->
<div id="status" data-init="@get('/sse/status')">Loading...</div>

<!-- CORRECT: data-signals activates DataStar processing -->
<div id="status" data-signals="{}" data-init="@get('/sse/status')">Loading...</div>
```

## CRITICAL: Signal Transport (GET requests)

When DataStar makes a `@get('/endpoint')` request, it bundles ALL signals into a single `datastar` JSON query parameter:

```
GET /sse/leads?datastar={"source":"devto","status":"","page":1}
```

**NOT** individual params like `?source=devto&page=1`. Your backend MUST parse this JSON param manually. See SSE Events reference for Python/FastAPI example.

## 2. Actions (Backend Requests)

Helper functions prefixed with `@`:

```html
<!-- GET request -->
<button data-on:click="@get('/data')">Load</button>

<!-- POST with loading indicator -->
<button data-on:click="@post('/save')"
        data-indicator:saving>
    <span data-show="!$saving">Save</span>
    <span data-show="$saving" style="display:none">Saving...</span>
</button>

<!-- Other methods -->
<button data-on:click="@put('/update')">Update</button>
<button data-on:click="@patch('/partial')">Patch</button>
<button data-on:click="@delete('/item')">Delete</button>
```

**Payload optimization:**
```html
<!-- Only send specific signals -->
<button data-on:click="@post('/click', {filterSignals: {include: /^(player_id|target_id)$/}})">
    Click
</button>
```

## 3. Backend Responses

**HTML (text/html)** - Morphs elements by ID:
```html
<!-- Frontend -->
<div id="result"></div>

<!-- Backend returns -->
<div id="result">Updated content</div>
```

**JSON (application/json)** - Merges signals:
```javascript
{count: 42, name: 'Jane'}
```

**SSE (text/event-stream)** - Streams multiple events:
```
event: datastar-patch-elements
data: elements <div id="foo">Content</div>

event: datastar-patch-signals
data: signals {count: 5}
```

## Event Modifiers

```html
<!-- Debounce/throttle -->
<input data-on:input__debounce-500="@get('/search')" />
<div data-on:scroll__throttle-100="@post('/track')" />

<!-- Window/document events -->
<div data-on:resize__window="$width = window.innerWidth" />
<div data-on:click__outside="$showMenu = false" />

<!-- Key events -->
<input data-on:keydown__enter="@post('/submit')" />
<input data-on:keydown__escape="$showModal = false" />

<!-- Event control -->
<button data-on:click__once="@get('/init')" />
```

## State Persistence

**localStorage:**
```html
<div data-signals="{theme: 'dark'}"
     data-persist:settings>
</div>
```

**URL query string:**
```html
<div data-signals="{search: '', page: 1}"
     data-query-string__history>
</div>
```
