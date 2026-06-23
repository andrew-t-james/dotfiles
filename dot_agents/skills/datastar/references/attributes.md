# Datastar Attributes Reference

## State Management

### data-signals
Define reactive state variables.

```html
<!-- Single signal -->
<div data-signals:foo="'initial'"></div>

<!-- Multiple signals -->
<div data-signals="{foo: 'bar', count: 0}"></div>

<!-- Nested signals -->
<div data-signals="{user: {name: 'John', age: 30}}"></div>
```

**Naming modifiers:**
- `__case` - Override default camelCase conversion: `.camel` (default), `.snake`, `.kebab`, `.pascal`
- `__ifmissing` - Only set if signal doesn't exist

### data-bind
Two-way binding between signal and element value.

```html
<input data-bind:username />
<input data-bind:email type="email" />
```

**Modifiers:**
- `__case.{camel|kebab|snake|pascal}` - Signal-name casing conversion
- `__prop.{propertyName}` - **(v1.0)** Bind through a specific DOM property instead of the inferred default. Example: `data-bind:is-checked__prop.checked`
- `__event.{event1}.{event2}` - **(v1.0)** Define which events sync element back to signal. Example: `data-bind:query__event.input.change`
- `__number` - Parse as number
- `__debounce` - Debounce updates (ms)

**v1.0 behavior:** `data-bind` now respects the initial `checked` property of radio buttons. Improved morphing of `input`, `select`, `textarea`. A new `datastar-prop-change` event fires instead of the native `change` event whenever a property is changed during morphing.

### data-computed
Create derived read-only signals.

```html
<!-- Inline expression -->
<div data-computed:fullName="$firstName + ' ' + $lastName"></div>

<!-- Object syntax -->
<div data-computed="{total: () => $price * $quantity}"></div>
```

### data-ref
Store element reference as signal.

```html
<div data-ref:myDiv></div>
<button data-on:click="$myDiv.classList.toggle('active')">Toggle</button>
```

## Display & Visibility

### data-text
Set text content from expression.

```html
<div data-text="$count"></div>
<div data-text="$name.toUpperCase()"></div>
```

### data-show
Toggle element visibility.

```html
<div data-show="$isVisible"></div>
<div data-show="$count > 5"></div>
```

### data-class
Conditionally add/remove classes.

```html
<!-- Single class -->
<div data-class:active="$isActive"></div>

<!-- Multiple classes -->
<div data-class="{active: $isActive, hidden: !$isVisible}"></div>
```

### data-attr
Set element attributes.

```html
<!-- Single attribute -->
<button data-attr:disabled="$loading">Submit</button>

<!-- Multiple attributes -->
<div data-attr="{title: $tooltip, disabled: $loading}"></div>
```

## Events

### data-on
Attach event listeners.

```html
<!-- Click event -->
<button data-on:click="$count++">Increment</button>

<!-- Multiple events -->
<input data-on:input="$value = el.value" 
	   data-on:blur="@post('/save')">

<!-- Custom events -->
<div data-on:mycustomevent="$data = evt.detail"></div>
```

**Event modifiers:**
- `__window` - Listen on window
- `__document` - **(v1.0)** Listen on document (useful for non-bubbling events)
- `__outside` - Trigger when event occurs outside element
- `__once` - Fire only once (built-in events only)
- `__passive` - Passive event listener — don't call `preventDefault` (built-in events only)
- `__capture` - Capture phase (built-in events only)
- `__prevent` - Call `preventDefault`
- `__stop` - Call `stopPropagation`
- `__case.{camel|kebab|snake|pascal}` - Event-name casing (default: kebab)
- `__delay.500ms` | `.1s` - Delay listener execution
- `__debounce.500ms[.leading][.notrailing]` - Debounce (ms/s)
- `__throttle.500ms[.noleading][.trailing]` - Throttle (ms/s)
- `__viewtransition` - Wrap in `document.startViewTransition()` (v1.0: no longer interferes with other modifiers)

**Key modifiers:**
- `__enter`, `__escape`, `__space`, `__up`, `__down`, etc.

### data-indicator
Set signal to true during request.

```html
<button data-on:click="@get('/data')" 
		data-indicator:loading>
	Fetch
</button>
<div data-show="$loading">Loading...</div>
```

## Side Effects

### data-effect
Execute expression when signals change.

```html
<div data-effect="console.log($count)"></div>
<div data-effect="$count > 10 && @post('/alert')"></div>
```

## Persistence

### data-persist
Persist signals to localStorage.

```html
<!-- Default key -->
<div data-persist></div>

<!-- Custom key -->
<div data-persist:myKey></div>
```

**Modifiers:**
- `__session` - Use sessionStorage

### data-query-string
Sync signals with URL query params.

```html
<div data-query-string></div>
<div data-query-string="{include: /search/, exclude: /temp/}"></div>
```

**Modifiers:**
- `__filter` - Filter empty values
- `__history` - Enable browser history

## Evaluation Control

### data-init
Run once on element initialization.

```html
<!-- Initialize signals -->
<div data-init="$count = 0"></div>

<!-- SSE auto-connect on page load (verified working in RC.8) -->
<div data-signals="{}" data-init="@get('/sse/endpoint')">
    <div id="content">Loading...</div>
</div>
```

**IMPORTANT (verified Feb 2026):** `data-init` DOES support backend actions (`@get`/`@post`) in RC.8. It fires once when the element enters the DOM.

**There is NO `data-on:load` event** in DataStar. Use `data-init` for page-load triggers, NOT `data-on:load`.

**Requirement:** The element (or an ancestor) MUST have `data-signals` for DataStar to process it. Even an empty `data-signals="{}"` is sufficient.

### data-match-media (NEW in RC.8)
Sets a signal to `true`/`false` based on a CSS media query, keeps it synced.

```html
<!-- Responsive signal: true when screen is narrow -->
<div data-match-media:is_mobile="(max-width: 768px)"></div>
<div data-show="$is_mobile">Mobile layout</div>
<div data-show="!$is_mobile">Desktop layout</div>
```

### data-intersects
Execute when element enters viewport.

```html
<div data-intersects="@get('/load-more')"></div>
```

**Options:**
- `threshold` - Intersection threshold (0-1)
- `rootMargin` - Margin around root
- `root` - Root element selector
