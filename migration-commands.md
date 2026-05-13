# Migration Command Reference
## ripgrep + tree-sitter commands used to analyse the Rails frontend for NuxtJS porting

---

## ripgrep Commands

### 1. List all HTML view files (pages)
```bash
rg "\.html\.erb$" app/views --files
```
**Purpose:** Find every file that renders a full HTML page. Each result = one Nuxt `pages/` file to create.
**Output used in Step 3?** ✅ Yes — Input 1. Identified which URLs have a corresponding rendered page, forming the basis of the Nuxt pages directory structure.

**Sample output:**
```
app/views/boards/new.html.erb
app/views/boards/show.html.erb
app/views/dashboard/index.html.erb
app/views/organizations/edit.html.erb
app/views/organizations/index.html.erb
app/views/organizations/new.html.erb
app/views/organizations/show.html.erb
app/views/projects/edit.html.erb
app/views/projects/new.html.erb
app/views/tasks/edit.html.erb
app/views/tasks/new.html.erb
app/views/tasks/show.html.erb
... (42 files total)
```
**How to read it:** The folder name tells you the resource (`boards`, `tasks`). The filename tells you the action (`show`, `new`, `edit`). Files starting with `_` are partials — they are NOT in this list, they are covered by command 2.

---

### 2. List all partial files (components)
```bash
rg --files -g "_*.html.erb" app/views
```
**Purpose:** Find every partial (reusable UI snippet). Each result = one Vue component to create.
**Note:** An earlier version of this command (`rg "_.*\.html\.erb$" app/views --files`) was incorrect — it matched underscores in folder names, not just filenames. The `-g` glob flag fixes this by matching against the filename only.
**Output used in Step 3?** ✅ Yes — Input 1. Confirmed which partials exist and need to become Vue components.

**Sample output:**
```
app/views/tasks/_task_card.html.erb
app/views/tasks/_form.html.erb
app/views/columns/_column.html.erb
app/views/columns/_form.html.erb
app/views/columns/_add_button.html.erb
app/views/comments/_comment.html.erb
app/views/comments/_form.html.erb
app/views/layouts/_flash.html.erb
app/views/layouts/_sidebar.html.erb
app/views/layouts/_topbar.html.erb
... (17 partials total)
```
**How to read it:** Every file starting with `_` is a partial. `layouts/_sidebar.html.erb` → `components/AppSidebar.vue`. `tasks/_task_card.html.erb` → `components/TaskCard.vue`.

---

### 3. List all partials rendered across the app
```bash
rg -o -I 'render "[^"]*"' app/views --type erb | sort | uniq
```
**Purpose:** Find every unique partial that is rendered somewhere in the app. Produces a clean deduplicated list of component names.
**Flags explained:**
- `-o` — print only the matched portion, not the whole line
- `-I` / `--no-filename` — suppress filename prefix so `sort | uniq` can deduplicate properly
- `[^"]*` — match any characters that are not a closing quote (captures the full partial name)
**Output used in Step 3?** ✅ Yes — Input 1. The 17 unique partials found here became the Vue component list.

**Sample output:**
```
render "boards/form"
render "columns/add_button"
render "columns/column"
render "columns/form"
render "comments/comment"
render "comments/form"
render "devise/shared/error_messages"
render "labels/form"
render "layouts/flash"
render "layouts/sidebar"
render "layouts/topbar"
render "notifications/notification"
render "organizations/form_errors"
render "organizations/form"
render "projects/form"
render "tasks/form"
render "tasks/task_card"
```
**How to read it:** Each line is a unique `render` call found anywhere in the app. Notice `devise/shared/error_messages` and `organizations/form_errors` do the same job — they can be merged into a single `FormErrors.vue` component in Nuxt.

---

### 4. Find files containing Turbo Stream interactions
```bash
rg -l "turbo_stream" app/views
```
**Purpose:** Find every view file that uses Turbo Streams for dynamic page updates. Each result = a dynamic interaction that needs a dedicated JSON API endpoint in Rails for Nuxt to call.
**Flag explained:**
- `-l` — list matching filenames only (not the matching lines)
**Note:** An earlier version used `--files` instead of `-l`. These are opposite flags: `--files` lists all files ripgrep would search (ignores the pattern entirely), while `-l` lists only files containing a match.
**Output used in Step 3?** ✅ Yes — Input 2. The turbo stream files identified which actions on each page are dynamic, directly producing the list of POST/PATCH/DELETE API endpoints needed.

**Sample output:**
```
app/views/columns/create.turbo_stream.erb
app/views/columns/destroy.turbo_stream.erb
app/views/columns/move.turbo_stream.erb
app/views/columns/update.turbo_stream.erb
app/views/comments/create.turbo_stream.erb
app/views/comments/destroy.turbo_stream.erb
app/views/comments/update.turbo_stream.erb
app/views/notifications/mark_read.turbo_stream.erb
app/views/tasks/create.turbo_stream.erb
app/views/tasks/destroy.turbo_stream.erb
app/views/tasks/move.turbo_stream.erb
app/views/tasks/update.turbo_stream.erb
```
**How to read it:** The filename encodes both the resource and the action. `columns/move.turbo_stream.erb` → `PATCH /api/columns/:id/move` endpoint needed. `comments/create.turbo_stream.erb` → `POST /api/comments` endpoint needed. Every file here is a dynamic interaction Rails currently handles with HTML fragments — Nuxt replaces each with a JSON API call.

---

### 5. Find all data-controller wiring (Stimulus)
```bash
rg "data-controller" app/views --type erb
```
**Purpose:** Find every place a Stimulus JavaScript controller is attached to a DOM element. Each unique controller name = interactive behaviour that must be re-implemented in Vue (e.g. `drag_controller.js` → `useDragAndDrop.ts` composable).
**Output used in Step 3?** ⚠️ Indirectly — informed which Vue components need interactive behaviour beyond simple data display.

**Sample output:**
```
app/views/boards/show.html.erb:    data-controller="drag">
app/views/layouts/_flash.html.erb: data-controller="flash"
app/views/layouts/_topbar.html.erb:data-controller="notification"
app/views/tasks/show.html.erb:     data-controller="modal"
```
**How to read it:** Format is `filename:matched_line`. The value after `data-controller=` is the Stimulus controller name. `drag` → `drag_controller.js` handles kanban drag-and-drop — this logic must become a Vue composable (e.g. `useDragAndDrop.ts`). Each unique controller name is a piece of JavaScript behaviour to port.

---

## tree-sitter Commands

### 6. Verify installation
```bash
tree-sitter --version
which tree-sitter
```
**Purpose:** Confirm the CLI is installed and locate it on disk.
**Output used in Step 3?** ❌ No — setup only.

**Sample output:**
```
tree-sitter 0.26.8
/opt/homebrew/bin/tree-sitter
```
**How to read it:** The version number confirms you have the CLI. The path confirms Homebrew installed it correctly at `/opt/homebrew/bin/tree-sitter`.

---

### 7. Configure grammar locations
```bash
mkdir -p ~/.config/tree-sitter
echo '{"parser-directories": ["'$HOME'/tree-sitter-grammars"]}' > ~/.config/tree-sitter/config.json
```
**Purpose:** Tell tree-sitter where to find installed language grammars. Without this config, tree-sitter cannot parse any language — it needs grammar rules for Ruby/ERB.
**Output used in Step 3?** ❌ No — setup only.

**Sample output** (from `cat ~/.config/tree-sitter/config.json`):
```json
{"parser-directories": ["/Users/srapngai/tree-sitter-grammars"]}
```
**How to read it:** The `parser-directories` array tells tree-sitter where to look for grammar folders. It will search inside each listed directory for a subfolder named `tree-sitter-ruby`.

---

### 8. Parse a source file (explore the syntax tree)
```bash
tree-sitter parse /path/to/app/models/task.rb
```
**Purpose:** Read a Ruby file and print its full syntax tree — every node type, named field, and exact line/column coordinates. Used to understand the shape of the tree *before* writing queries against it.
**Output used in Step 3?** ❌ No — used for learning/exploration only.

**Sample output** (abbreviated from `task.rb`):
```
(program [0, 0] - [48, 0]
  (class [0, 0] - [47, 3]
    name: (constant [0, 6] - [0, 10])
    body: (body_statement [1, 2] - [46, 5]
      (call [7, 2] - [7, 21]
        method: (identifier [7, 2] - [7, 12])
        arguments: (argument_list [7, 13] - [7, 21]
          (simple_symbol [7, 13] - [7, 21])))
      (call [18, 2] - [18, 49]
        method: (identifier [18, 2] - [18, 10])
        arguments: (argument_list [18, 11] - [18, 49]
          (simple_symbol [18, 11] - [18, 28])
          (pair
            key: (hash_key_symbol) "dependent"
            value: (simple_symbol) ":destroy")))
      ...)))
```
**How to read it:** Each `(node_type [line, col] - [line, col])` is one piece of code. Lines/columns are zero-indexed — add 1 to match your editor. Named fields like `method:`, `arguments:`, `key:`, `value:` describe each child's role. Indentation shows nesting. This output is what you study to design a query — you identify which node types to match and which fields to capture.

---

### 9. Query: find direct has_many associations (no through:)
**Query file:** `has_many.scm`
```scheme
(call
  method: (identifier) @method (#eq? @method "has_many")
  arguments: (argument_list
    (simple_symbol) @association) @args
  (#not-match? @args "through:"))
```
```bash
tree-sitter query /path/to/has_many.scm /path/to/app/models/task.rb
```
**Purpose:** Extract all `has_many` associations that do NOT use `through:`. These are direct associations (e.g. `:comments`, `:subtasks`) plus bridge tables (`:taggings`, `:task_assignments`).
**Predicates explained:**
- `(#eq? @method "has_many")` — only match calls where the method name is exactly `has_many`
- `@args` — captures the full argument list as text
- `(#not-match? @args "through:")` — exclude any call whose arguments contain the text `through:`
**Output used in Step 3?** ✅ Yes — Input 3 (partial). Found direct associations per model. Required cross-referencing with Query 10 to remove bridge tables.

**Sample output** (against `task.rb`):
```
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:subtasks`
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:task_assignments`
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:comments`
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:taggings`
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:activity_logs`
```
**How to read it:** Each `pattern: 0` block is one match. The `capture: 1 - association` line is what you care about — `text:` is the association name. Notice `:task_assignments` and `:taggings` appear here even though they are bridge tables — they have no `through:` in their own declaration so the filter cannot remove them. Cross-reference with Query 10 output to identify and exclude them.

---

### 10. Query: find through: associations (destinations across bridges)
**Query file:** `has_many_through.scm`
```scheme
(call
  method: (identifier) @method (#eq? @method "has_many")
  arguments: (argument_list
    (simple_symbol) @association) @args
  (#match? @args "through:"))
```
```bash
tree-sitter query /path/to/has_many_through.scm /path/to/app/models/task.rb
```
**Purpose:** Extract all `has_many` associations that DO use `through:`. These are the real destination associations the frontend cares about (e.g. `:labels`, `:assignees`).
**Note:** This is the complement of Query 9. The only change is `#not-match?` → `#match?`.
**Output used in Step 3?** ✅ Yes — Input 3 (completes the picture). The `through:` destinations (`:labels`, `:assignees`) are exactly what must be included in the API JSON response.

**Sample output** (against `task.rb`):
```
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:assignees`
pattern: 0
  capture: 0 - method,      text: `has_many`
  capture: 1 - association,  text: `:labels`
```
**How to read it:** Only two results — the `through:` destinations. `:assignees` = user avatars on the task card. `:labels` = coloured badge chips on the task card. Both must appear in the `GET /api/tasks/:id` JSON response.

---

### 11. Scale query across all models (bash loop)
```bash
for f in /path/to/app/models/*.rb; do
  echo "=== $(basename $f) ===";
  tree-sitter query /path/to/has_many.scm "$f" 2>/dev/null | grep "association";
done
```
**Purpose:** Run a tree-sitter query against every model file at once. Produces a full association map across the entire codebase in one command.
**Shell explained:**
- `for f in .../*.rb` — iterate over every `.rb` file
- `$(basename $f)` — strip the directory path, show only the filename
- `2>/dev/null` — suppress parse errors for files that don't match
- `| grep "association"` — filter output to only the captured association names
**Output used in Step 3?** ✅ Yes — Input 3. This produced the complete association map used to determine what each API endpoint must `include:` in its JSON response.

**Sample output:**
```
=== activity_log.rb ===
=== application_record.rb ===
=== board.rb ===
    capture: 1 - association, text: `:columns`
=== column.rb ===
    capture: 1 - association, text: `:tasks`
=== comment.rb ===
    capture: 1 - association, text: `:activity_logs`
=== organization.rb ===
    capture: 1 - association, text: `:memberships`
    capture: 1 - association, text: `:projects`
=== project.rb ===
    capture: 1 - association, text: `:project_members`
    capture: 1 - association, text: `:boards`
    capture: 1 - association, text: `:tasks`
    capture: 1 - association, text: `:labels`
=== task.rb ===
    capture: 1 - association, text: `:subtasks`
    capture: 1 - association, text: `:task_assignments`
    capture: 1 - association, text: `:comments`
    capture: 1 - association, text: `:taggings`
    capture: 1 - association, text: `:activity_logs`
=== user.rb ===
    capture: 1 - association, text: `:memberships`
    capture: 1 - association, text: `:project_members`
    capture: 1 - association, text: `:created_tasks`
    capture: 1 - association, text: `:task_assignments`
    capture: 1 - association, text: `:comments`
    capture: 1 - association, text: `:notifications`
    capture: 1 - association, text: `:activity_logs`
```
**How to read it:** Models with no `has_many` (like `activity_log.rb`) produce no output under their header. Models with associations list each one. Read this top-down to answer "when Nuxt fetches a board, what can it ask to include?" — `board` → `columns` → (from column.rb section) `tasks`. This chain defines the nested JSON shape of the API response.

---

## How the Three Inputs Combined in Step 3

```
INPUT 1 (ripgrep: routes + view files)
  → "What pages and actions exist?"
  → Produced: list of Nuxt pages and HTTP verbs per resource

INPUT 2 (ripgrep: turbo_stream files)
  → "Which interactions are dynamic?"
  → Produced: list of POST/PATCH/DELETE API endpoints needed per page

INPUT 3 (tree-sitter: has_many queries)
  → "What data does each model carry?"
  → Produced: JSON response shape (what to include:) for each GET endpoint

ALL THREE COMBINED
  → Complete API contract: for every Nuxt page,
    which endpoints to call and what data shape to expect
```

---

## Key Flag Reference

| Flag | Tool | Meaning |
|---|---|---|
| `--files` | rg | List all files rg *would* search — ignores the pattern |
| `-l` | rg | List files that *contain* a match |
| `-o` | rg | Print only the matched portion, not the whole line |
| `-I` | rg | Suppress filename prefix in output |
| `-g` | rg | Filter by glob pattern (applied to filename only, not full path) |
| `--type erb` | rg | Search only inside `.erb` files |
| `2>/dev/null` | bash | Discard error output |
| `@capture` | tree-sitter | Label a matched node for extraction |
| `(#eq? @x "y")` | tree-sitter | Predicate: match only if capture equals string |
| `(#match? @x "y")` | tree-sitter | Predicate: match only if capture contains pattern |
| `(#not-match? @x "y")` | tree-sitter | Predicate: match only if capture does NOT contain pattern |
