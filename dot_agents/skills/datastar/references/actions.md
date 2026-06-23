# Datastar Actions Reference

Actions are helper functions prefixed with `@` that provide secure, sandboxed operations.

## Backend Actions

### @get(url, options?)
Send GET request.

```html
<button data-on:click="@get('/data')">Fetch</button>
<button data-on:click="@get('/api', {indicator: 'loading'})">Load</button>
```

### @post(url, options?)
Send POST request.

```html
<button data-on:click="@post('/save')">Save</button>
```

### @put(url, options?)
Send PUT request.

```html
<button data-on:click="@put('/update')">Update</button>
```

### @patch(url, options?)
Send PATCH request.

```html
<button data-on:click="@patch('/partial')">Patch</button>
```

### @delete(url, options?)
Send DELETE request.

```html
<button data-on:click="@delete('/item')">Delete</button>
```

## Request Options (v1.0.0)

All backend actions accept an options object. Full option list from the v1.0 reference:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `contentType` | string | `'json'` | Request encoding: `'json'` or `'form'` |
| `filterSignals` | object | `{include: /.*/}` | Filter signals via regex: `{include, exclude}` |
| `selector` | string\|null | `null` | CSS selector for form element (form contentType) |
| `headers` | object | `{}` | Custom HTTP headers |
| `openWhenHidden` | boolean | `false` for `@get`, `true` for others | Keep SSE connection open when page hidden |
| `payload` | object | `undefined` | Override fetch payload with custom object |
| `retry` | string | `'auto'` | Retry strategy: `'auto'`, `'error'`, `'always'`, `'never'` |
| `retryInterval` | number | `1000` | Initial retry delay (ms) |
| `retryScaler` | number | `2` | Multiplier for exponential backoff |
| `retryMaxWait` | number | `30000` | **(v1.0: renamed from `retryMaxWaitMs`)** Max wait between retries (ms) |
| `retryMaxCount` | number | `10` | Maximum retry attempts |
| `requestCancellation` | string\|AbortController | `'auto'` | Concurrency: `'auto'`, `'cleanup'`, `'disabled'`, or controller instance |

```javascript
// Example with v1.0 options
@get('/data', {
    retry: 'auto',
    retryInterval: 1000,
    retryMaxWait: 30000,       // was retryMaxWaitMs in pre-1.0
    retryMaxCount: 10,
    filterSignals: {include: /^user/}
})
```

**v1.0 behavior changes:**
- `Content-Type: application/json` header is now set ONLY for requests that contain a body.
- A `body` is now sent ONLY for non-GET and non-DELETE requests.
- The `fetch` action now resends the payload when reconnecting after a tab visibility change.

## Frontend Actions

### @setAll(value, filter?)
Set all matching signals to value.

```html
<!-- Set all signals -->
<button data-on:click="@setAll(0)">Reset All</button>

<!-- Set specific signals -->
<button data-on:click="@setAll(true, {include: /^flag/})">Enable Flags</button>

<!-- Exclude certain signals -->
<button data-on:click="@setAll('', {include: /.*/, exclude: /_temp$/})">Clear</button>
```

### @toggleAll(filter?)
Toggle all matching boolean signals.

```html
<!-- Toggle all booleans -->
<button data-on:click="@toggleAll()">Toggle All</button>

<!-- Toggle specific signals -->
<button data-on:click="@toggleAll({include: /^menu\.isOpen\./})">Toggle Menus</button>
```

### @peek(expression)
Access signal without subscribing to changes.

```html
<!-- This won't re-evaluate when $bar changes -->
<div data-text="@peek($bar) + $foo"></div>
```

## Response Types

### text/html
Morphs elements into DOM by ID.

```html
<!-- Backend returns -->
<div id="result">Updated content</div>
```

### application/json
Merges signals using JSON Merge Patch.

```javascript
// Backend returns
{foo: 'bar', count: 42}
```

### text/event-stream
Streams Server-Sent Events.

```
event: datastar-patch-elements
data: elements <div id="foo">content</div>

event: datastar-patch-signals
data: signals {count: 5}
```

### text/javascript
Executes JavaScript.

```javascript
// Backend returns
console.log('Hello from server');
alert('Data saved');
```

## Fetch Events

All backend actions trigger lifecycle events:

- `datastar-fetch:started` - Request begins
- `datastar-fetch:progress` - Download progress (ReadableStream)
- `datastar-fetch:ended` - Request completes
- `datastar-fetch:error` - Request fails

```html
<div data-on:datastar-fetch:started="$loading = true"
	 data-on:datastar-fetch:ended="$loading = false">
</div>
```
