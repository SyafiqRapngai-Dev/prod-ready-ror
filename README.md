# RoR Sample App — Project Management

A production-ready Kanban project management app built with **Ruby on Rails 8**. Designed as a learning codebase for tracing Rails conventions with tools like ripgrep and tree-sitter, and as a reference for porting the frontend to another language.

Inspired by Linear / Jira. Supports multiple organizations, projects, Kanban boards, tasks, comments, labels, notifications, and full-text search.

---

## Tech Stack

| Layer           | Technology                          |
| --------------- | ----------------------------------- |
| Framework       | Rails 8.0.4, Ruby ~> 3.3            |
| Database        | PostgreSQL                          |
| Auth            | Devise 4.9                          |
| Authorization   | Pundit 2.5                          |
| Frontend        | Tailwind CSS, Turbo, Stimulus       |
| Background Jobs | Sidekiq 7.3 + Redis                 |
| Search          | pg_search 2.3                       |
| Pagination      | Pagy 9.0                            |
| Testing         | RSpec, FactoryBot, shoulda-matchers |

---

## Prerequisites

- Ruby 3.3+
- PostgreSQL 14+
- Redis (for Sidekiq)
- Bundler (`gem install bundler`)

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repo-url>
cd ror-sample-app
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Configure environment

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

Minimum required variables:

```
DATABASE_URL=postgresql://localhost/ror_sample_app_development
REDIS_URL=redis://localhost:6379/0
```

> If you don't have a `.env.example`, create a `.env` file with the variables above.

### 4. Set up the database

```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed data creates:

| Email             | Password    | Role                             |
| ----------------- | ----------- | -------------------------------- |
| alice@example.com | password123 | Owner (Acme Corp + Pixel Studio) |
| bob@example.com   | password123 | Admin (Acme Corp)                |
| carol@example.com | password123 | Member (Acme Corp)               |
| dave@example.com  | password123 | Manager (Pixel Studio)           |
| eve@example.com   | password123 | Member (Pixel Studio)            |

### 5. Start the app

You need two processes running:

**Terminal 1 — Rails server:**

```bash
rails server
```

**Terminal 2 — Sidekiq (background jobs):**

```bash
bundle exec sidekiq
```

Visit [http://localhost:3000](http://localhost:3000) and sign in as `alice@example.com` / `password123`.

---

## Running Tests

```bash
bundle exec rspec
```

Run a specific file:

```bash
bundle exec rspec spec/models/task_spec.rb
bundle exec rspec spec/policies/organization_policy_spec.rb
bundle exec rspec spec/requests/organizations_spec.rb
```

---

## Project Structure

```
app/
├── controllers/        # 12 resource controllers + ApplicationController
├── models/             # 14 models (User, Organization, Project, Task, ...)
├── policies/           # Pundit authorization policies
├── views/              # ERB templates (Turbo Streams for live updates)
├── jobs/               # Sidekiq background jobs
├── javascript/
│   └── controllers/    # Stimulus controllers (drag, modal, flash, notification)
└── helpers/

config/
├── routes.rb           # Full nested route tree
└── importmap.rb        # JS dependencies (no npm/webpack)

spec/
├── factories/          # FactoryBot factories for all 14 models
├── models/             # Model unit tests
├── policies/           # Pundit policy tests
├── requests/           # Integration tests
└── support/            # Shared test helpers
```

### Key URL patterns

| Resource      | URL pattern                                     |
| ------------- | ----------------------------------------------- |
| Organizations | `/organizations/:slug`                          |
| Projects      | `/organizations/:slug/projects/:key`            |
| Board         | `/organizations/:slug/projects/:key/boards/:id` |
| Tasks         | `/organizations/:slug/projects/:key/tasks/:id`  |
| Search        | `/search?q=...`                                 |
| Notifications | `/notifications`                                |

---

## Codebase Conventions

This app is intentionally written in idiomatic Rails to make it easy to trace:

- **Authentication** — `before_action :authenticate_user!` in `ApplicationController`; Devise handles sessions
- **Authorization** — every controller action calls `authorize @resource`; policies live in `app/policies/`
- **Turbo Streams** — mutating actions respond to both `turbo_stream` and `html` formats
- **Background jobs** — `NotificationJob` and `ActivityLogJob` are enqueued from model callbacks
- **Scopes** — models expose named scopes (e.g. `Task.overdue`, `Notification.unread`)
- **Enums** — integer-backed enums on `Membership#role`, `Project#status`, `Task#priority`

### Useful ripgrep searches

```bash
# Find all Pundit policy checks
rg "authorize "

# Find all Turbo Stream responses
rg "turbo_stream"

# Find all background job enqueues
rg "perform_later"

# Find all named scopes
rg "scope :"

# Find all enum definitions
rg "enum :"
```

---

## Porting the Frontend

The backend exposes conventional Rails HTML responses. To port the frontend:

1. Replace ERB views with your target framework (React, Vue, Svelte, etc.)
2. Use the existing controller actions as a JSON API by adding `format.json` responses
3. All business logic stays in models, policies, and jobs — untouched

---

## License

MIT
