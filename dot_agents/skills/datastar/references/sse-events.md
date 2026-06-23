# Server-Sent Events (SSE) Reference

SSE responses use `Content-Type: text/event-stream`

## ⚠️ IMPORTANT: Datastar 1.0 Event Names

**Datastar 1.0 changed SSE event names.** Using old names will silently fail:

| v0.x (DEPRECATED)        | v1.0 (CURRENT)           |
|-------------------------|--------------------------|
| `datastar-merge-signals`   | `datastar-patch-signals`   |
| `datastar-merge-fragments` | `datastar-patch-elements`  |
| `data: {json}`             | `data: signals {json}`     |
| `data: fragments <html>`   | `data: elements <html>`    |

## Core Events

### datastar-patch-elements
Add/update/remove DOM elements.

**Basic morphing (default):**
```
event: datastar-patch-elements
data: elements <div id="foo">New content</div>
```

**With options:**
```
event: datastar-patch-elements
data: mode morph
data: selector #container
data: useViewTransition true
data: elements <div>Content</div>
```

**⚠️ IMPORTANT: Order matters!** The `data:` lines should follow this order:
1. `mode` (if using non-default)
2. `selector` (if targeting specific element)
3. `elements` (the HTML content - LAST)

Example for appending to timeline:
```
event: datastar-patch-elements
data: mode append
data: selector #timeline
data: elements <article id="post-123">Content</article>
```

**Merge modes:**
- `morph` (default) - Intelligent DOM diffing
- `inner` - Replace innerHTML
- `outer` - Replace outerHTML
- `prepend` - Add before first child
- `append` - Add after last child
- `before` - Insert before element
- `after` - Insert after element
- `delete` - Remove element
- `upsertAttributes` - Update attributes only

### datastar-patch-signals
Add/update/remove signals.

**Basic patch:**
```
event: datastar-patch-signals
data: signals {foo: 'bar', count: 42}
```

**Delete signals:**
```
event: datastar-patch-signals
data: signals {obsolete: null}
```

**Only if missing:**
```
event: datastar-patch-signals
data: onlyIfMissing true
data: signals {default: 'value'}
```

### datastar-execute-script
Execute JavaScript on frontend.

```
event: datastar-execute-script
data: script console.log('Hello from server')
```

**With attributes:**
```
event: datastar-execute-script
data: attributes {"type": "module"}
data: script import {foo} from './bar.js'; foo();
```

## Response Headers

### For application/json responses:
- `datastar-only-if-missing: true` - Only patch missing signals

### For text/javascript responses:
- `datastar-script-attributes: {"type":"module"}` - Set script attributes

## SDK Examples

### Go (Official SDK - RECOMMENDED)
```go
import "github.com/starfederation/datastar-go/datastar"

sse := datastar.NewSSE(w, r)

// Patch signals (map or struct)
sse.MarshalAndPatchSignals(map[string]any{
    "stream_connected": true,
    "count": 42,
})

// Patch elements with options
sse.PatchElements(
    `<div id="foo">Content</div>`,
    datastar.WithSelector("#container"),
    datastar.WithMode(datastar.ElementPatchModeAppend),
)

// Element patch modes:
// datastar.ElementPatchModeOuter (default - morph)
// datastar.ElementPatchModeInner
// datastar.ElementPatchModeAppend
// datastar.ElementPatchModePrepend
// datastar.ElementPatchModeBefore
// datastar.ElementPatchModeAfter
// datastar.ElementPatchModeRemove
// datastar.ElementPatchModeReplace

// Remove element
sse.RemoveElement("#old-item")

// Execute script
sse.ExecuteScript(`alert('Done')`)

// Redirect
sse.Redirect("/new-page")

// Read signals from request
type Signals struct {
    Foo string `json:"foo"`
}
signals := &Signals{}
datastar.ReadSignals(request, signals)

// Check if connection closed
ctx := sse.Context()
<-ctx.Done() // blocks until client disconnects
```

### Python (with SDK)
```python
from datastar_py import ServerSentEventGenerator as SSE

@app.get('/data')
async def handler(request):
	yield SSE.patch_elements('<div id="foo">Content</div>')
	await asyncio.sleep(1)
	yield SSE.patch_signals({'count': 5})
```

### Python/Flask (manual SSE - no SDK)
```python
import json
from flask import Flask, Response

def sse_signals(data):
    """Create SSE signals event for Datastar 1.0"""
    return f"event: datastar-patch-signals\ndata: signals {json.dumps(data)}\n\n"

def sse_elements(selector, html, mode='inner'):
    """Create SSE elements event for Datastar 1.0
    For multiline HTML, each line needs 'data: elements ' prefix."""
    lines = ["event: datastar-patch-elements"]
    if selector:
        lines.append(f"data: selector {selector}")
    if mode:
        lines.append(f"data: mode {mode}")
    for line in html.strip().splitlines():
        lines.append(f"data: elements {line}")
    lines.append("")
    lines.append("")
    return "\n".join(lines)

def sse_redirect(url):
    """Execute redirect via SSE script"""
    return f"event: datastar-execute-script\ndata: script window.location.href = '{url}'\n\n"

@app.route('/api/data')
def get_data():
    body = ""
    body += sse_signals({'count': 42, 'name': 'John'})
    body += sse_elements('#timer', '<span>0:00</span>')
    return Response(body, content_type='text/event-stream')
```

### Python/FastAPI (manual SSE - no SDK)

**CRITICAL:** DataStar sends all signals as a single JSON query param `?datastar={...}`, NOT as individual query params. You MUST parse this manually:

```python
import json
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse

app = FastAPI()

def parse_ds_signals(request: Request) -> dict:
    """Parse DataStar signals from ?datastar= query parameter."""
    raw = request.query_params.get("datastar", "{}")
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return {}

def sse_fragment(html: str, selector: str = "", mode: str = "morph") -> str:
    """Format multiline HTML as a DataStar v1.0 SSE event."""
    lines = ["event: datastar-patch-elements"]
    if selector:
        lines.append(f"data: selector {selector}")
    if mode:
        lines.append(f"data: mode {mode}")
    for line in html.strip().splitlines():
        lines.append(f"data: elements {line}")
    lines.append("")
    lines.append("")
    return "\n".join(lines)

@app.get("/sse/data")
async def sse_data(request: Request):
    # Parse signals from DataStar's bundled JSON param
    signals = parse_ds_signals(request)
    page = int(signals.get("page", 0))
    search = signals.get("search") or None

    # ... query database using signal values ...

    html = "<div id='result'>Content</div>"
    sse = sse_fragment(html, selector="#result", mode="inner")

    async def generate():
        yield sse

    return StreamingResponse(generate(), media_type="text/event-stream",
                             headers={"Cache-Control": "no-cache"})
```

**Common mistake:** Using FastAPI's typed query params (`page: int = 0`) — these will ALWAYS be defaults because DataStar bundles everything in `?datastar={...}`.

### PHP
```php
use starfederation\datastar\ServerSentEventGenerator;

$sse = new ServerSentEventGenerator();
$sse->patchElements('<div id="foo">Content</div>');
$sse->patchSignals(['count' => 5]);

// Read signals
$signals = $sse->readSignals();
```

### .NET
```csharp
using StarFederation.Datastar.DependencyInjection;

builder.Services.AddDatastar();

app.MapGet("/", async (IDatastarService ds) =>
{
	await ds.PatchElementsAsync(@"<div id=""foo"">Content</div>");
	await Task.Delay(1000);
	await ds.PatchSignalsAsync(new { count = 5 });
});
```

### Node.js
```javascript
const { ServerSentEventGenerator } = require('datastar');

ServerSentEventGenerator.stream(req, res, (stream) => {
	stream.patchElements(`<div id="foo">Content</div>`);
	
	setTimeout(() => {
		stream.patchSignals({count: 5});
	}, 1000);
});
```

## Long-Lived Connections

SSE connections can remain open for real-time updates:

```
event: datastar-patch-signals
data: signals {time: '10:00'}

event: datastar-patch-signals
data: signals {time: '10:01'}

event: datastar-patch-signals
data: signals {time: '10:02'}
```

Close connection when done or use `openWhenHidden: false` to pause when page hidden.
