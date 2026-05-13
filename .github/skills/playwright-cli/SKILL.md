---
name: playwright-cli
description: >
  Use when you need to automate browser interactions for page exploration, element discovery,
  screenshots, navigation, storage, or network inspection. Covers all playwright-cli commands,
  snapshot-based targeting, session management, and headed/attached operation.
  Trigger phrases: open browser, navigate to url, take screenshot, get page snapshot,
  click element, fill form, explore page with playwright-cli.
allowed-tools: Bash(playwright-cli:*) Bash(npx:*) Bash(npm:*)
---

# Browser Automation with playwright-cli

`playwright-cli` is the CLI interface to Playwright. It is preferred over Playwright MCP in coding
agents because it is token-efficient — it does not load large tool schemas or verbose accessibility
trees into the model context, and it exposes every interaction as a concise shell command.

## Quick Start

```bash
# Open browser and navigate
playwright-cli open https://example.com

# Take a snapshot to discover element refs
playwright-cli snapshot

# Interact using a ref from the snapshot
playwright-cli click e15
playwright-cli fill e3 "hello world"
playwright-cli press Enter

# Save a screenshot
playwright-cli screenshot --filename=docs/page-state.png

# Close the browser
playwright-cli close
```

## Commands

### Core

```bash
playwright-cli open [url]              # open browser, optionally navigate
playwright-cli goto <url>              # navigate to a url
playwright-cli close                   # close the browser

playwright-cli snapshot                # capture full page snapshot (returns element refs)
playwright-cli snapshot --filename=f   # save snapshot to specific file
playwright-cli snapshot <ref>          # snapshot a specific element
playwright-cli snapshot --depth=N      # limit snapshot depth for efficiency
playwright-cli snapshot --boxes        # include bounding boxes [x,y,w,h] in snapshot

playwright-cli click <ref> [button]    # click an element (left/right/middle)
playwright-cli dblclick <ref>          # double-click an element
playwright-cli fill <ref> <text>       # fill text into editable element
playwright-cli fill <ref> <text> --submit   # fill and press Enter
playwright-cli type <text>             # type text into the focused element
playwright-cli hover <ref>             # hover over an element
playwright-cli select <ref> <val>      # select an option in a dropdown
playwright-cli check <ref>             # check a checkbox or radio
playwright-cli uncheck <ref>           # uncheck a checkbox or radio
playwright-cli drag <startRef> <endRef>  # drag and drop between two elements
playwright-cli drop <ref> --path=<file>  # drop a file onto an element
playwright-cli upload <file>           # upload a file via file input
playwright-cli eval "expr"             # evaluate JS on the page
playwright-cli eval "el => el.textContent" <ref>   # evaluate JS on an element
playwright-cli dialog-accept [prompt]  # accept a dialog
playwright-cli dialog-dismiss          # dismiss a dialog
playwright-cli resize <w> <h>          # resize the browser window
playwright-cli delete-data             # delete session data
```

### Navigation

```bash
playwright-cli go-back
playwright-cli go-forward
playwright-cli reload
```

### Keyboard

```bash
playwright-cli press Enter
playwright-cli press ArrowDown
playwright-cli press Tab
playwright-cli keydown Shift
playwright-cli keyup Shift
```

### Mouse

```bash
playwright-cli mousemove 150 300
playwright-cli mousedown
playwright-cli mousedown right
playwright-cli mouseup
playwright-cli mousewheel 0 100
```

### Save as

```bash
playwright-cli screenshot                        # screenshot of current page
playwright-cli screenshot <ref>                  # screenshot of a specific element
playwright-cli screenshot --filename=page.png    # save with specific filename
playwright-cli pdf --filename=page.pdf
```

### Tabs

```bash
playwright-cli tab-list
playwright-cli tab-new [url]
playwright-cli tab-close [index]
playwright-cli tab-select <index>
```

### Storage

```bash
playwright-cli state-save [filename]     # save storage (auth) state to file
playwright-cli state-load <filename>     # load storage state from file

# Cookies
playwright-cli cookie-list [--domain=example.com]
playwright-cli cookie-get <name>
playwright-cli cookie-set <name> <value> [--domain=] [--httpOnly] [--secure]
playwright-cli cookie-delete <name>
playwright-cli cookie-clear

# LocalStorage
playwright-cli localstorage-list
playwright-cli localstorage-get <key>
playwright-cli localstorage-set <key> <value>
playwright-cli localstorage-delete <key>
playwright-cli localstorage-clear

# SessionStorage
playwright-cli sessionstorage-list
playwright-cli sessionstorage-get <key>
playwright-cli sessionstorage-set <key> <value>
playwright-cli sessionstorage-delete <key>
playwright-cli sessionstorage-clear
```

### Network

```bash
playwright-cli requests                  # list all network requests since page load
playwright-cli request <index>           # show full details for a request
playwright-cli request-headers <index>
playwright-cli request-body <index>
playwright-cli response-headers <index>
playwright-cli response-body <index>
playwright-cli route <pattern>           # mock requests matching a url pattern
playwright-cli route "**/*.jpg" --status=404
playwright-cli route "https://api.example.com/**" --body='{"mock":true}'
playwright-cli route-list
playwright-cli unroute [pattern]
playwright-cli network-state-set offline
playwright-cli network-state-set online
```

### DevTools

```bash
playwright-cli console [min-level]         # list console messages
playwright-cli run-code "async page => await page.title()"
playwright-cli run-code --filename=script.js
playwright-cli tracing-start
playwright-cli tracing-stop
playwright-cli video-start [filename]
playwright-cli video-chapter "Chapter Title"
playwright-cli video-stop
playwright-cli show                        # open visual dashboard
playwright-cli show --annotate             # open dashboard for UI review / annotation
playwright-cli generate-locator <ref>      # generate a Playwright locator string for an element
playwright-cli generate-locator <ref> --raw
playwright-cli highlight <ref>             # show a persistent highlight overlay
playwright-cli highlight <ref> --style="outline: 3px dashed red"
playwright-cli highlight <ref> --hide
playwright-cli highlight --hide            # hide all highlights
```

## Targeting Elements

After every command playwright-cli prints a snapshot of the page with numbered element refs (e.g. `e5`, `e12`). Use these refs in subsequent commands.

```bash
# 1. get snapshot
playwright-cli snapshot

# 2. use a ref from the snapshot
playwright-cli click e15
playwright-cli fill e3 "hello"
```

You can also target elements directly with CSS selectors or Playwright locators:

```bash
# CSS selector
playwright-cli click "#main > button.submit"

# role locator
playwright-cli click "getByRole('button', { name: 'Submit' })"

# test id
playwright-cli click "getByTestId('submit-button')"
```

## Snapshots

Every command returns a snapshot automatically. Take one explicitly when needed:

```bash
# default — timestamp-based filename
playwright-cli snapshot

# save to a specific file (good for workflow artefacts)
playwright-cli snapshot --filename=after-login.yaml

# limit depth for large pages, then drill into a section
playwright-cli snapshot --depth=4
playwright-cli snapshot e34
```

## Open Parameters

```bash
playwright-cli open --browser=chrome     # chrome | firefox | webkit | msedge
playwright-cli open --headed             # show the browser window
playwright-cli open --persistent         # persist profile to disk
playwright-cli open --profile=/path      # use a specific profile directory
playwright-cli open --config=cli.json    # use a config file
playwright-cli attach --extension=chrome # connect via Playwright Extension
playwright-cli attach --cdp=chrome       # attach to running Chrome/Edge by channel
playwright-cli attach --cdp=http://localhost:9222  # attach via CDP endpoint
playwright-cli detach                    # detach, leaves external browser running
```

## Sessions

Playwright CLI keeps state in memory by default. Use `-s=<name>` to manage named sessions.

```bash
playwright-cli -s=app open https://example.com --persistent
playwright-cli -s=app snapshot
playwright-cli -s=app click e5
playwright-cli -s=app close

playwright-cli list           # list all sessions
playwright-cli close-all      # close all browsers
playwright-cli kill-all       # forcefully kill all browser processes
```

Set `PLAYWRIGHT_CLI_SESSION=<name>` to use a named session without the `-s=` flag.

## Raw / JSON Output

```bash
# --raw: strip page status and snapshot, return only the result value
playwright-cli --raw eval "document.title"
playwright-cli --raw eval "JSON.stringify([...document.querySelectorAll('a')].map(a=>a.href))" > links.json
playwright-cli --raw snapshot > before.yml
playwright-cli click e5
playwright-cli --raw snapshot > after.yml
diff before.yml after.yml

# --json: wrap every response as JSON
playwright-cli list --json
```

## Installation

```bash
# Check if globally installed
playwright-cli --version

# If not available, use local version
npx --no-install playwright-cli --version

# Install globally
npm install -g @playwright/cli@latest
```

## Common Workflows

### Form Submission

```bash
playwright-cli open https://example.com/login
playwright-cli snapshot
playwright-cli fill e1 "user@example.com"
playwright-cli fill e2 "password123"
playwright-cli click e3
playwright-cli snapshot
playwright-cli close
```

### Save Auth State for Reuse

```bash
playwright-cli open https://example.com/login
playwright-cli fill e1 "user@example.com"
playwright-cli fill e2 "password123"
playwright-cli click e3
playwright-cli state-save auth.json
playwright-cli close

# Load state in a later session
playwright-cli open https://example.com
playwright-cli state-load auth.json
playwright-cli goto https://example.com/dashboard
```

### Screenshot at Each State

```bash
playwright-cli open https://example.com
playwright-cli screenshot --filename=docs/landing.png
playwright-cli click e7
playwright-cli screenshot --filename=docs/menu-open.png
playwright-cli close
```

### Multi-tab Workflow

```bash
playwright-cli open https://example.com
playwright-cli tab-new https://example.com/other
playwright-cli tab-list
playwright-cli tab-select 0
playwright-cli snapshot
playwright-cli close
```

### Mock a Network Request

```bash
playwright-cli open https://example.com
playwright-cli route "https://api.example.com/data" --body='{"items":[]}'
playwright-cli reload
playwright-cli snapshot
playwright-cli close
```

### Inspect Network Traffic

```bash
playwright-cli open https://example.com
playwright-cli requests
playwright-cli request 3
playwright-cli response-body 3
playwright-cli close
```

### Debug with Tracing

```bash
playwright-cli open https://example.com
playwright-cli tracing-start
playwright-cli click e4
playwright-cli fill e7 "test"
playwright-cli tracing-stop
playwright-cli close
```
