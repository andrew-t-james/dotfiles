# DataStar Gotchas

## Quick Reference

| # | Issue | Symptom | Fix |
|---|-------|---------|-----|
| 1 | Signal naming (camelCase) | Hyphenated attrs auto-convert to camelCase | Use camelCase: `playerName`, or `__case.snake` to opt into snake_case |
| 2 | Server-side state only | State resets, can't access localStorage | Move ALL state to server |
| 3 | Missing IDs | Wrong element updates | Add unique `id=` to morphed elements |
| 4 | FOUC on data-show | Flash of content before JS loads | Add `style="display:none"` |
| 5 | PHP output buffering | SSE hangs, "network error" | `while (ob_get_level()) ob_end_clean();` |
| 6 | SSE event names (v1.0) | Events not received | Use `datastar-patch-*` not `datastar-merge-*` |
| 7 | Signals not defined | Expression errors | Define parent signals before children |
| 8 | JSON response merge | Signals not deleted | Use `{obsolete: null}` to delete |
| 9 | SSE stays open | Connection persists | Close explicitly when done |
| 10 | No loops in DataStar | Trying to iterate in HTML | Render lists on backend, send HTML |
| 11 | Not a JS library | Accessing window.Datastar | Use declarative HTML attributes only |
| 12 | Event chaining wrong | All fetches trigger handler | Use `data-effect` not `data-on:datastar-fetch` |
| 13 | filterSignals syntax | Payload filtering fails | Use regex: `{filterSignals: {include: /^id$/}}` |
| 14 | executeScript unsupported | Script events ignored | Use MutationObserver instead (RC.8) |
| 15 | CSS animations work | Wondering about transitions | Use keyframe animations, they work! |
| 16 | Patch multiple fragments | Need to update several areas | Call `patchElements` multiple times |
| 17 | Elements must exist | `PatchElementsNoTargetsFound` | Render hidden elements, don't conditionally skip |
| 18 | Sibling signals shared | All buttons send same value | Set signal explicitly in click handler |
| 19 | Animation restart | Animation doesn't replay | Add `data-ts="timestamp"` to force re-render |
| 20 | CDN URL 404 | DataStar not loaded, no errors | Use `gh/starfederation/datastar` not `npm/@starfederation/datastar` |
| 21 | `data-on:load` doesn't exist | SSE never fires on page load | Use `data-init` for initialization, NOT `data-on:load` |
| 22 | Signals not received by backend | All query params are defaults | Parse `?datastar={...}` JSON param, not individual query params |
| 23 | `data-signals` scope required | `data-init`/`data-on:*` silently ignored | Add `data-signals="{}"` on element or ancestor |
| 24 | Block-form statements break parser | Half the page works (everything before bad attr), the rest silently fails — `data-show`/`data-class`/`data-bind-*` no-op on later siblings/descendants. Console DOES log `datastar runtime error: GenerateExpression` (easy to miss — not a stack-trace `Uncaught Error`). | `;`-chained statements OK. **Block syntax NOT** OK (`if (…) { … }`, `for { }`, `try { }`, bare `{ }`). Use ternary `?:` for branching, or delegate to `window.fn()` |

---

## Detailed Gotchas

### Gotcha #1: Signal Naming — camelCase is Default

**Official docs:** "Keys used in `data-signals:*` are converted to camel case (the recommended casing for signals)"

Hyphenated HTML attribute names auto-convert to camelCase:
- `data-bind:first-name` → signal `$firstName`
- `data-signals:game-over` → signal `$gameOver`

**Both of these work fine:**
```html
<div data-signals="{playerName: '', gameOver: false}">
<div data-signals="{player_name: '', game_over: false}">
```

**The `__case` modifier** lets you override conversion per-attribute:
```html
<input data-bind:my-signal__case.snake />  <!-- → $my_signal -->
<input data-bind:my-signal__case.camel />  <!-- → $mySignal (default) -->
<input data-bind:my-signal__case.pascal /> <!-- → $MySignal -->
```

**Rule:** Signal names CANNOT begin with or contain `__` (double underscore) — reserved for modifier syntax. Signals starting with `_` (single underscore) are excluded from backend requests.

---

### Gotcha #2: Server-Side State is MANDATORY

DataStar expressions run in a **sandboxed Function() constructor**. They CANNOT access:
- `window` or `document`
- `localStorage` or `sessionStorage`
- Global variables (even if set via `window.myVar`)

**NEVER use localStorage for cart/user state with DataStar.** This is the #1 mistake.

**Correct approach (The DataStar Way):**
- Store ALL state on the server (session, cookie, database)
- Signals mirror server state, not client storage
- Every `@post`/`@get` sends signals -> server updates state -> returns SSE
- Server is the **single source of truth**

**Wrong approach (will waste hours debugging):**
- Storing cart in localStorage
- Trying to read localStorage in DataStar expressions
- Custom events to bridge JS <-> DataStar
- Vanilla JS workarounds for state

**See:** https://data-star.dev/shop for official shopping cart example

---

### Gotcha #3: Missing IDs

**Symptom:** Wrong element updates, morphing fails.

Elements that will be updated by SSE MUST have `id` attributes.

```html
<!-- Wrong - no ID -->
<div class="result"></div>

<!-- Correct -->
<div id="result" class="result"></div>
```

---

### Gotcha #4: FOUC (Flash of Unstyled Content)

**Problem:** Elements with `data-show` flash visible before JS loads.

**Fix:** Add inline style to hide by default:
```html
<div data-show="$loading" style="display:none">Loading...</div>
```

---

### Gotcha #5: PHP Output Buffering Breaks SSE

**Symptom:** SSE endpoint hangs, no events received, "network error" in console.

**Fix:** Add at TOP of PHP SSE handler:
```php
// CRITICAL: Disable ALL output buffering (WordPress adds multiple levels)
while (ob_get_level()) {
    ob_end_clean();
}
set_time_limit(0);
ignore_user_abort(true);

header('Content-Type: text/event-stream');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('X-Accel-Buffering: no'); // Nginx
header('Connection: keep-alive');

// Disable compression
ini_set('output_buffering', 'off');
ini_set('zlib.output_compression', false);
if (function_exists('apache_setenv')) {
    apache_setenv('no-gzip', '1');
}
```

---

### Gotcha #6: SSE Event Names Changed (v1.0)

**Old (deprecated):**
```
event: datastar-merge-signals
event: datastar-merge-fragments
```

**New (use these):**
```
event: datastar-patch-signals
data: signals {count: 5}

event: datastar-patch-elements
data: elements <div id="foo">Content</div>
```

---

### Gotcha #7: Signals Must Be Defined Before Use

Define parent signals before using them in children. DOM order matters.

```html
<!-- Wrong - using undefined signal -->
<div data-text="$count"></div>
<div data-signals="{count: 0}">...</div>

<!-- Correct - define first -->
<div data-signals="{count: 0}">
    <div data-text="$count"></div>
</div>
```

---

### Gotcha #10: NO LOOPS IN DATASTAR

DataStar does NOT have `data-for` or iteration. Render lists on backend and send HTML via `datastar-patch-elements`.

**Wrong (won't work):**
```html
<div data-for="item in $items">...</div>
```

**Correct:**
```html
<!-- Frontend -->
<div id="items-list"></div>

<!-- Backend sends HTML -->
event: datastar-patch-elements
data: elements <div id="items-list"><div>Item 1</div><div>Item 2</div></div>
```

---

### Gotcha #12: Event Chaining - Use data-effect

Don't use `data-on:datastar-fetch` for chaining - it's a global listener that triggers for ALL fetch events.

**Wrong:**
```html
<div data-on:datastar-fetch:success="@get('/next')">...</div>
```

**Correct - Use data-effect:**
```html
<div data-signals="{joined: false, connected: false}"
     data-effect="$joined && !$connected && @get('/stream')">
</div>
```

---

### Gotcha #13: filterSignals Syntax

Use regex patterns, not arrays.

**Wrong:**
```html
<button data-on:click="@post('/api', {only: ['id', 'name']})">
```

**Correct:**
```html
<button data-on:click="@post('/api', {filterSignals: {include: /^(id|name)$/}})">
```

---

### Gotcha #17: Elements Must Exist for Patching

Elements that SSE will patch MUST exist in DOM. Use `style="display:none"` instead of conditional PHP.

**Wrong:**
```php
<?php if ($show_notice): ?>
    <div id="notice">...</div>
<?php endif; ?>
```

**Correct:**
```html
<div id="notice" style="<?= $show_notice ? '' : 'display:none' ?>">...</div>
```

---

### Gotcha #18: CRITICAL - Sibling Signals Share Global State

When multiple sibling elements define the same signal name, they share GLOBAL state - last value wins!

**Wrong - all buttons send last product's ID:**
```html
{% for product in products %}
<article data-signals="{product_id: '{{ product.id }}'}">
    <button data-on:click="@post('/api/cart/add')">Add</button>
</article>
{% endfor %}
```

**Correct - set signal explicitly in click:**
```html
<section data-signals="{product_id: ''}">
{% for product in products %}
<article>
    <button data-on:click="$product_id = '{{ product.id }}'; @post('/api/cart/add')">Add</button>
</article>
{% endfor %}
</section>
```

---

### Gotcha #19: Animation Restart on Re-patch

When patching the same element multiple times (e.g., toast notifications), CSS animations won't restart because browser sees same element.

**Fix:** Add unique attribute to force re-render:
```html
<div class="toast" data-ts="<?= time() ?>">Message</div>
```

Or generate timestamp in backend:
```php
Datastar::patchElements('<div class="toast" data-ts="' . time() . '">Saved!</div>');
```

---

### Gotcha #20: CDN URL Returns 404

**Symptom:** DataStar not loaded, no JS errors (script just silently fails), no reactivity.

**Wrong (404):**
```html
<script type="module" src="https://cdn.jsdelivr.net/npm/@starfederation/datastar@1/bundles/datastar.js"></script>
```

**Correct:**
```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.0/bundles/datastar.js"></script>
```

The npm package `@starfederation/datastar` doesn't have the `bundles/` directory on jsdelivr. Use the GitHub (`gh/`) path instead.

---

### Gotcha #21: `data-on:load` Does Not Exist

**Symptom:** SSE request never fires on page load. No errors.

**Wrong:**
```html
<div data-on:load="@get('/sse/data')">Loading...</div>
```

**Correct:**
```html
<div data-init="@get('/sse/data')">Loading...</div>
```

`data-on:*` is for DOM events (`click`, `change`, `input`, etc.). There is no `load` DOM event on arbitrary divs. Use `data-init` for initialization actions.

---

### Gotcha #22: Backend Doesn't Receive Signal Values

**Symptom:** All filter/pagination params are None or defaults. Server returns unfiltered data despite user selecting filters.

**Cause:** DataStar bundles ALL signals into a single `?datastar={...}` JSON query param:
```
GET /sse/leads?datastar={"source":"devto","page":1,"search":"john"}
```

**Wrong (signals will always be None):**
```python
@app.get("/sse/leads")
async def sse_leads(source: str = None, page: int = 0):
    # source is ALWAYS None, page is ALWAYS 0
```

**Correct:**
```python
@app.get("/sse/leads")
async def sse_leads(request: Request):
    signals = json.loads(request.query_params.get("datastar", "{}"))
    source = signals.get("source") or None
    page = int(signals.get("page", 0))
```

---

### Gotcha #23: `data-signals` Scope Required

**Symptom:** `data-init`, `data-on:*`, `data-bind:*` are silently ignored. No errors.

**Cause:** DataStar only activates on elements within a `data-signals` scope.

**Wrong (data-init ignored):**
```html
<div id="status" data-init="@get('/sse/status')">Loading...</div>
```

**Correct:**
```html
<div id="status" data-signals="{}" data-init="@get('/sse/status')">Loading...</div>
```

Even an empty `data-signals="{}"` is sufficient. The scope can be on the element itself or any ancestor.

---

### Gotcha #24: Block-form Statements Break the Expression Parser

**Symptom:** Half the page works (everything *before* the offending attribute in DOM order); everything after silently fails — `data-show`, `data-class`, `data-bind-*` no-op, conditional sections all visible at once. The page looks like Datastar didn't load. Console DOES contain `datastar runtime error: GenerateExpression` — but it's a custom-named error (not `Uncaught Error`), thrown from a microtask, easy to miss.

**Cause:** Datastar's expression compiler (`genRX` in source) tokenizes the attribute value on `;` (string-aware), wraps the **last token** in `return (${last});`, joins with `;`, then passes the body to `new Function()`. For block-form constructs like `if (cond) { stmt1; stmt2; }`, the last token after `;`-split is `}` — wrapped becomes `return (});` → SyntaxError at compile time. The error throws from `genRX`, propagates through the plugin walker, **aborts traversal of remaining sibling/descendant elements** so they never get their data-* plugins attached.

**Wrong (silently breaks page):**
```html
<button data-on-click="if (confirm('Sure?')) { doX(); doY(); }">Click</button>
```

**Wrong (block syntax):**
```html
<div data-on-click="{ a; b; c; }">…</div>
<div data-on-click="for (let i=0; i<3; i++) { … }">…</div>
<div data-on-click="try { x(); } catch (e) { y(); }">…</div>
```

**Right — semicolon-chained statements (officially supported):**
```html
<div data-on-click="$x = 1; $y = 2; $z = 3">…</div>
```

**Right — ternary for branching:**
```html
<button data-on-click="$confirm ? window.doIt() : null">Click</button>
```

**Right — delegate to function (best for multi-statement logic):**
```html
<button data-on-click="window.app.handleClick()">Click</button>
```
```js
window.app = {
  handleClick() {
    if (confirm('Sure?')) { doX(); doY(); }
  }
};
```

**Why this matters more than the docs let on:** the official "Datastar Expressions" guide explicitly says *"Multiple statements can be used in a single expression by separating them with a semicolon"* — which is true for `;`-chained assignments/calls. But it doesn't warn that **block syntax** breaks the parser, and the failure mode (silent partial mount) makes it look like a totally different bug.

**Source evidence:** `Pn` function in `dist/datastar.js`:
```js
let r = /(\/(\\\/|[^\/])*\/|"(\\"|[^\"])*"|'(\\'|[^'])*'|`(\\`|[^`])*`|[^;])+/gm,
    i = t.value.trim().match(r);
if (i) {
  let A = i.length - 1, h = i[A].trim();
  h.startsWith("return") || (i[A] = `return (${h});`);  // ← last token always wrapped
  n = i.join(";");
}
let b = `return (() => {\n${n}\n})()`;
new Function("ctx", ...e, b);  // ← throws SyntaxError on block-end
```

**Debug tip:** if Datastar seems to "stop working halfway through the page", grep your template for `data-on-*=".*\\{` and `data-effect=".*\\{` — block-form is the usual suspect.
