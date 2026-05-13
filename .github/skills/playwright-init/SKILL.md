---
name: playwright-init
description: 'Use when initializing a new Playwright project from scratch, or when a Playwright scaffold is not yet present. Covers installing Playwright, creating the required folder structure, tsconfig.json, and playwright.config.ts. Trigger phrases: init playwright, setup playwright, no playwright installed, install playwright.'
---

# Playwright Project Initialization

## When to Use

- A `package.json` exists but `@playwright/test` is not installed
- `playwright.config.ts` / `playwright.config.js` is missing
- The `tests/` folder does not exist
- The user asks to set up Playwright from scratch

---

## Step 1 — Detect Existing State

Before running anything, check for:

| File / folder                | Command                                     |
| ---------------------------- | ------------------------------------------- |
| `package.json`               | `test -f package.json`                      |
| `@playwright/test` installed | `cat package.json \| grep @playwright/test` |
| `playwright.config.ts`       | `test -f playwright.config.ts`              |
| `tsconfig.json`              | `test -f tsconfig.json`                     |

Only run the steps that are actually missing. Never re-initialise what already exists.

---

## Step 2 — Install Playwright

If `@playwright/test` is not in `package.json` dependencies:

```bash
npm init -y              # only if package.json is missing
npm install -D @playwright/test
npm install -D @types/node
npx playwright install --with-deps
```

> Always install `@types/node` so TypeScript can resolve Node.js globals (`process`, `__dirname`, etc.) used in `playwright.config.ts` and `global-setup.ts`.

> `--with-deps` installs OS-level browser dependencies (needed in CI and clean macOS environments).

Do **not** run `npm init playwright@latest` — it overwrites config files and adds unwanted examples.

---

## Step 3 — Create `tsconfig.json`

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

## Step 4 — Create `playwright.config.ts`

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
mkdir -p playwright/pages playwright/fixtures playwright/tests playwright/test-data playwright/docs
```

Expected layout after init:

```
<project-root>/
├── playwright/
│   ├── pages/
│   ├── fixtures/
│   │   └── index.ts        ← create with base re-export (see below)
│   ├── tests/
│   ├── test-data/
│   └── docs/
├── playwright.config.ts
└── tsconfig.json
```

### `playwright/fixtures/index.ts` base content (if not present):

```typescript
import { test as base, expect } from '@playwright/test';

export const test = base;
export { expect };
```

---

## Step 6 — Verify Installation

Run a quick smoke check:

```bash
npx playwright test --list
```

Expected: lists 0 tests (no spec files yet) without errors.
If it errors, diagnose before proceeding — common causes:

- Missing `tsconfig.json` → create it (Step 3)
- Wrong `testDir` in config → correct the path
- Browsers not installed → re-run `npx playwright install`

---

## Step 7 — First Test Run

On the **very first** run after generating test files, always run with `--update-snapshots` to create visual regression baselines:

```bash
npx playwright test --update-snapshots
```

- Do **not** terminate the session until all tests pass.
- If tests fail, diagnose each failure, fix the code, and re-run until the full suite is green.
- Only after all tests pass is the session complete.

---

## Checklist

- [ ] `@playwright/test` in `devDependencies`
- [ ] `@types/node` in `devDependencies`
- [ ] Browsers installed (`npx playwright install`)
- [ ] `tsconfig.json` present with `types: ["node", "@playwright/test"]`
- [ ] `playwright.config.ts` present with correct `testDir` and `baseURL`
- [ ] `pages/`, `fixtures/`, `tests/`, `test-data/` folders exist
- [ ] `fixtures/index.ts` re-exports `test` and `expect`
- [ ] `npx playwright test --list` runs without errors
- [ ] First run uses `npx playwright test --update-snapshots` and all tests pass
