---
name: playwright-init
description: 'Use when initializing a new Playwright project from scratch, or when a Playwright scaffold is not yet present. Covers installing Playwright, creating the required folder structure, tsconfig.json, and playwright.config.ts. Trigger phrases: init playwright, setup playwright, no playwright installed, install playwright.'
---

# Playwright Project Initialization

## When to Use

- An `e2e/package.json` exists but `@playwright/test` is not installed
- `e2e/playwright.config.ts` / `e2e/playwright.config.js` is missing
- The `e2e/tests/` folder does not exist
- The user asks to set up Playwright from scratch

---

## Step 1 — Detect Existing State

Before running anything, check for:

| File / folder                | Command                                         |
| ---------------------------- | ----------------------------------------------- |
| `e2e/package.json`           | `test -f e2e/package.json`                      |
| `@playwright/test` installed | `cat e2e/package.json \| grep @playwright/test` |
| `e2e/playwright.config.ts`   | `test -f e2e/playwright.config.ts`              |
| `e2e/tsconfig.json`          | `test -f e2e/tsconfig.json`                     |

Only run the steps that are actually missing. Never re-initialise what already exists.

---

## Step 2 — Install Playwright

If `@playwright/test` is not in `e2e/package.json` dependencies:

```bash
mkdir -p e2e
cd e2e
npm init -y              # only if e2e/package.json is missing
npm install -D @playwright/test
npm install -D @types/node
npx playwright install --with-deps
cd ..
```

> All npm commands run from inside `e2e/` so that `node_modules/`, `package.json`, and `package-lock.json` are all scoped to the `e2e/` directory.

> Always install `@types/node` so TypeScript can resolve Node.js globals (`process`, `__dirname`, etc.) used in `e2e/playwright.config.ts` and `e2e/global-setup.ts`.

> `--with-deps` installs OS-level browser dependencies (needed in CI and clean macOS environments).

Do **not** run `npm init playwright@latest` — it overwrites config files and adds unwanted examples.

---

## Step 3 — Create `e2e/tsconfig.json`

Always create this if missing. Required for TypeScript path resolution and strict type-checking with Playwright.

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "types": ["node", "@playwright/test"]
  }
}
```

---

## Step 4 — Create `e2e/playwright.config.ts`

Create only if missing. Use this minimal, correct template:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  use: {
    baseURL: 'https://your-app-url.com', // ← update this
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

> Set `baseURL` to the target app URL so tests can use relative paths like `page.goto('/')`.

---

## Step 5 — Create Folder Structure

Create any missing folders (do not overwrite existing ones):

```
mkdir -p e2e/pages e2e/fixtures e2e/tests e2e/test-data e2e/docs
```

Expected layout after init:

```
<project-root>/
└── e2e/
    ├── node_modules/
    ├── package.json
    ├── package-lock.json
    ├── tsconfig.json
    ├── playwright.config.ts
    ├── pages/
    ├── fixtures/
    │   └── index.ts        ← create with base re-export (see below)
    ├── tests/
    ├── test-data/
    └── docs/
```

### `e2e/fixtures/index.ts` base content (if not present):

```typescript
import { test as base, expect } from '@playwright/test';

export const test = base;
export { expect };
```

---

## Step 6 — Verify Installation

Run a quick smoke check from inside `e2e/`:

```bash
cd e2e && npx playwright test --list
```

Expected: lists 0 tests (no spec files yet) without errors.
If it errors, diagnose before proceeding — common causes:

- Missing `e2e/tsconfig.json` → create it (Step 3)
- Wrong `testDir` in config → correct the path
- Browsers not installed → re-run `cd e2e && npx playwright install`

---

## Step 7 — First Test Run

On the **very first** run after generating test files, always run with `--update-snapshots` to create visual regression baselines:

```bash
cd e2e && npx playwright test --update-snapshots
```

- Do **not** terminate the session until all tests pass.
- If tests fail, diagnose each failure, fix the code, and re-run until the full suite is green.
- Only after all tests pass is the session complete.

---

## Checklist

- [ ] `e2e/` directory exists
- [ ] `@playwright/test` in `e2e/package.json` `devDependencies`
- [ ] `@types/node` in `e2e/package.json` `devDependencies`
- [ ] Browsers installed (`cd e2e && npx playwright install`)
- [ ] `e2e/tsconfig.json` present with `types: ["node", "@playwright/test"]`
- [ ] `e2e/playwright.config.ts` present with correct `testDir` and `baseURL`
- [ ] `e2e/pages/`, `e2e/fixtures/`, `e2e/tests/`, `e2e/test-data/` folders exist
- [ ] `e2e/fixtures/index.ts` re-exports `test` and `expect`
- [ ] `cd e2e && npx playwright test --list` runs without errors
- [ ] First run uses `cd e2e && npx playwright test --update-snapshots` and all tests pass
