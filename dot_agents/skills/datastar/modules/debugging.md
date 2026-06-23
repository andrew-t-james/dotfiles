# DataStar Debugging Guide

## Important: DataStar is NOT a JS Library

`window.Datastar` may not exist or should not be accessed directly. DataStar works through HTML attributes and server-side rendering.

## Debugging Approach

### 1. Check Network Tab
- Look for SSE connections (EventStream type)
- Verify SSE events are being received
- Check response format matches DataStar spec

### 2. Inspect Elements Tab
- Examine `data-*` attributes on elements
- Verify signal definitions exist
- Check IDs on elements that should morph

### 3. Check Server Logs
- Verify SSE events being sent
- Confirm correct headers
- Look for PHP errors/warnings

### 4. Common Quick Checks
- Signal names use camelCase? (default convention, or snake_case with `__case.snake`)
- Elements have `id=` for morphing?
- `style="display:none"` on data-show elements?
- PHP output buffering disabled?

## Common Error Messages

### "PatchElementsNoTargetsFound"
**Cause:** SSE trying to patch element that doesn't exist in DOM.
**Fix:** Render element with `style="display:none"` instead of conditionally skipping.

### "network error" / SSE retry loop
**Cause:** PHP output buffering or gzip compression.
**Fix:** Disable buffering at start of SSE handler:
```php
while (ob_get_level()) ob_end_clean();
```

### Signals not updating
**Possible causes:**
1. Signal name contains `__` (reserved for modifiers)
2. Signal not defined before use
3. Typo in signal name

### Button sends wrong ID (lists)
**Cause:** Sibling signals share global state.
**Fix:** Set signal explicitly in click handler:
```html
<button data-on:click="$id = 'value'; @post('/api')">
```

## DataStar Inspector

Browser extension available for monitoring:
- SSE events in real-time
- Signal values
- DOM mutations

## SSE Response Debugging

Check your SSE response format:
```
event: datastar-patch-elements
data: elements <div id="target">Content</div>

event: datastar-patch-signals
data: signals {"count": 5}

```
Note: Double newline (`\n\n`) required after each event.

## PHP SSE Debugging

Add debugging output before SSE:
```php
// Temporary debug - remove in production
error_log("SSE handler called");
error_log("Output buffer level: " . ob_get_level());
error_log("Headers sent: " . (headers_sent() ? 'yes' : 'no'));
```

Check PHP error log for issues.
