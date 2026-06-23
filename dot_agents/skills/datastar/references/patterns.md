# Datastar Common Patterns

## Form Handling

### Basic Form
```html
<form data-signals="{name: '', email: ''}">
	<input data-bind:name placeholder="Name" />
	<input data-bind:email type="email" placeholder="Email" />
	<button data-on:click="@post('/submit')">Submit</button>
</form>
```

### Form with Validation
```html
<form data-signals="{email: '', valid: false}"
	  data-computed:valid="$email.includes('@')">
	<input data-bind:email type="email" />
	<button data-attr:disabled="!$valid"
			data-on:click="@post('/submit')">
		Submit
	</button>
	<div data-show="!$valid && $email">Invalid email</div>
</form>
```

### Form with Loading State
```html
<form data-signals="{data: {}}">
	<button data-on:click="@post('/submit')"
			data-indicator:saving
			data-attr:disabled="$saving">
		<span data-show="!$saving">Save</span>
		<span data-show="$saving">Saving...</span>
	</button>
</form>
```

## Lists & Collections

### Dynamic List
```html
<div data-signals="{items: []}">
	<button data-on:click="@get('/load')">Load Items</button>
	
	<div data-show="$items.length">
		<div data-text="`${$items.length} items`"></div>
	</div>
</div>

<!-- Backend returns: {items: [{id: 1, name: 'A'}]} -->
```

### Infinite Scroll
```html
<div data-signals="{page: 1, hasMore: true}">
	<div id="items"></div>
	
	<div data-intersects="@get(`/load?page=${$page++}`)"
		 data-show="$hasMore">
		Loading more...
	</div>
</div>
```

## Conditional Rendering

### Toggle Visibility
```html
<div data-signals:visible="false">
	<button data-on:click="$visible = !$visible">Toggle</button>
	<div data-show="$visible">Hidden content</div>
</div>
```

### Conditional Classes
```html
<div data-signals:active="false">
	<button data-on:click="$active = !$active"
			data-class:btn-active="$active">
		Toggle
	</button>
</div>
```

### Multi-State UI
```html
<div data-signals:state="'idle'">
	<div data-show="$state === 'idle'">Ready</div>
	<div data-show="$state === 'loading'">Loading...</div>
	<div data-show="$state === 'success'">Done!</div>
	<div data-show="$state === 'error'">Error occurred</div>
</div>
```

## Real-Time Updates

### SSE Auto-Connect on Page Load
```html
<!-- Auto-connect to SSE stream when page loads -->
<div data-signals="{stream_connected: false}">
	<div data-effect="!$stream_connected && @get('/stream')"></div>
	<div id="timeline">
		<div data-show="!$stream_connected">Connecting...</div>
	</div>
</div>

<!-- Backend sends: event: datastar-patch-signals
     data: signals {"stream_connected": true} -->
```

**Important:** Use `data-effect` with a condition, NOT `data-init` for backend actions.

### Live Data (Button Trigger)
```html
<div data-signals:time="''">
	<button data-on:click="@get('/stream')">Start</button>
	<div data-text="$time"></div>
</div>

<!-- Backend streams updates every second -->
```

### Collaborative Editing
```html
<div data-signals="{doc: '', users: []}">
	<textarea data-bind:doc
			  data-on:input__debounce-500="@patch('/doc')"></textarea>
	
	<div data-text="`${$users.length} users online`"></div>
</div>

<!-- Backend broadcasts changes via SSE -->
```

## Complex State

### Nested Signals
```html
<div data-signals="{
	user: {
		name: '',
		prefs: {theme: 'dark', lang: 'en'}
	}
}">
	<input data-bind:user.name />
	<select data-bind:user.prefs.theme>
		<option value="light">Light</option>
		<option value="dark">Dark</option>
	</select>
</div>
```

### Computed Values
```html
<div data-signals="{cart: [], tax: 0.1}"
	 data-computed:subtotal="$cart.reduce((s,i) => s + i.price, 0)"
	 data-computed:total="$subtotal * (1 + $tax)">
	
	<div data-text="`Subtotal: $${$subtotal}`"></div>
	<div data-text="`Total: $${$total}`"></div>
</div>
```

## URL Sync

### Search with Query String
```html
<div data-signals="{search: '', page: 1}"
	 data-query-string__history>
	
	<input data-bind:search
		   data-on:input__debounce-300="@get('/search')" />
	
	<div data-text="`Page ${$page}`"></div>
</div>

<!-- URL updates: ?search=foo&page=2 -->
```

## Performance Patterns

### Debounced Input
```html
<input data-bind:query
	   data-on:input__debounce-500="@get('/search')" />
```

### Throttled Events
```html
<div data-on:scroll__throttle-100="@post('/track')">
	Scrollable content
</div>
```

### Lazy Loading
```html
<img data-intersects="el.src = '/image.jpg'"
	 data-attr:src="''" />
```

## Tab Navigation

### Basic Tabs
```html
<div data-signals:tab="'home'">
	<button data-on:click="$tab = 'home'"
			data-class:active="$tab === 'home'">
		Home
	</button>
	<button data-on:click="$tab = 'profile'"
			data-class:active="$tab === 'profile'">
		Profile
	</button>
	
	<div data-show="$tab === 'home'">Home content</div>
	<div data-show="$tab === 'profile'">Profile content</div>
</div>
```

### Tabs with Backend
```html
<div data-signals:tab="'home'">
	<button data-on:click="$tab = 'home'; @get('/home')">Home</button>
	<button data-on:click="$tab = 'profile'; @get('/profile')">Profile</button>
	
	<div id="content"></div>
</div>
```

## Modals & Dialogs

### Basic Modal
```html
<div data-signals:showModal="false">
	<button data-on:click="$showModal = true">Open</button>
	
	<div data-show="$showModal"
		 data-class:modal-open="$showModal">
		<div class="modal-content">
			<button data-on:click="$showModal = false">Close</button>
			Modal content
		</div>
	</div>
</div>
```

### Close on Outside Click
```html
<div data-signals:showModal="false">
	<button data-on:click="$showModal = true">Open</button>
	
	<div data-show="$showModal">
		<div class="modal-backdrop"
			 data-on:click__outside="$showModal = false">
			<div class="modal-content">
				Content
			</div>
		</div>
	</div>
</div>
```

## Progress Indicators

### Progress Bar
```html
<div data-signals:progress="0">
	<button data-on:click="@get('/process')">Start</button>
	
	<div class="progress-bar">
		<div class="progress-fill"
			 data-attr:style="`width: ${$progress}%`"></div>
	</div>
	<div data-text="`${$progress}% complete`"></div>
</div>

<!-- Backend streams progress updates -->
```

### Step Progress
```html
<div data-signals:step="1">
	<div data-class:completed="$step > 1">Step 1</div>
	<div data-class:completed="$step > 2">Step 2</div>
	<div data-class:completed="$step > 3">Step 3</div>
	
	<button data-on:click="$step++"
			data-show="$step < 3">
		Next
	</button>
</div>
```
