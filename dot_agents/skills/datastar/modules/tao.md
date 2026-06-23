# The Tao of Datastar

> Source: https://data-star.dev/guide/the_tao_of_datastar

Datastar is just a tool. The Tao of Datastar is a set of opinions from the core team on how to best use Datastar to build maintainable, scalable, high-performance web apps. Ignore them at your own peril!

## 1. State in the Right Place

Most state should live in the backend. Since the frontend is exposed to the user, the backend should be the source of truth for your application state.

## 2. Start with the Defaults

The default configuration options are the recommended settings for the majority of applications. Before you ever get tempted to change them, stop and ask yourself why.

## 3. Patch Elements & Signals

Since the backend is the source of truth, it should *drive* the frontend by **patching** (adding, updating and removing) HTML elements and signals.

## 4. Use Signals Sparingly

Overusing signals typically indicates trying to manage state on the frontend. Favor fetching current state from the backend. Only use signals for:
- User interactions (e.g. toggling element visibility)
- Sending new state to the backend (e.g. binding signals to form inputs)

## 5. In Morph We Trust

Morphing ensures that only modified parts of the DOM are updated, preserving state and improving performance. Send large chunks of the DOM tree (even up to the `html` tag — "fat morph") rather than managing fine-grained updates yourself. Use `data-ignore-morph` to exclude specific elements.

## 6. SSE Responses

SSE responses allow sending 0 to n events to patch elements, patch signals, and execute scripts. Since event streams are just HTTP responses with special formatting that SDKs handle, there's no real benefit to using a content type other than `text/event-stream`.

## 7. Compression

Since SSE streams events and morphing allows large DOM chunks, compressing the response is natural. Brotli compression ratios of 200:1 are not uncommon on streams.

## 8. Backend Templating

Since your backend generates HTML, use your templating language to keep things DRY (Don't Repeat Yourself).

## 9. Page Navigation

Use the anchor element (`<a>`) to navigate, or redirects from the backend. For smooth page transitions, use the View Transition API.

## 10. Browser History

Browsers automatically keep history. Don't manage it yourself — that adds complexity. Each page is a resource. Use anchor tags and let the browser do what it's good at.

## 11. CQRS (Command Query Responsibility Segregation)

Separate writes from reads: a single long-lived request receives updates (reads), while multiple short-lived requests make changes (writes). This makes real-time collaboration simple.

```html
<div id="main" data-init="@get('/cqrs_endpoint')">
    <button data-on:click="@post('/do_something')">
        Do something
    </button>
</div>
```

## 12. Loading Indicators

Use `data-indicator` to show loading state during backend requests:

```html
<button data-indicator:_loading
        data-on:click="@post('/do_something')">
    Do something
    <span data-show="$_loading">Loading...</span>
</button>
```

With CQRS, manually show loading and let the backend-driven DOM update hide it:

```html
<button data-on:click="el.classList.add('loading'); @post('/do_something')">
    Do something
    <span>Loading...</span>
</button>
```

## 13. Optimistic Updates — DON'T

Optimistic UI deceives the user by showing success before the backend confirms. Instead, use loading indicators and only confirm success from the backend.

## 14. Accessibility

Use semantic HTML, apply ARIA where it makes sense, and ensure your app works with keyboards and screen readers:

```html
<button data-on:click="$_menu_open = !$_menu_open"
        data-attr:aria-expanded="$_menu_open ? 'true' : 'false'">
    Open/Close Menu
</button>
<div data-attr:aria-hidden="$_menu_open ? 'false' : 'true'"></div>
```
