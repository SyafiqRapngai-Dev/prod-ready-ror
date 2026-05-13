---
name: playwright-pom
description: 'Use when setting up a new Playwright project with Page Object Model (POM), creating page objects, fixtures, or test-data files. Covers full project structure, locator patterns, fixture wiring, and typed test data.'
argument-hint: 'Optional: name of the page to scaffold (e.g. LoginPage)'
---

# Playwright POM Setup

## When to Use

- Starting a new Playwright project and want POM structure from scratch
- Adding a new Page Object to an existing project
- Wiring up a new custom fixture
- Creating typed test-data files

---

## Project Structure

Always use this folder layout:

```
<project-root>/
├── pages/                    # One file per page of the app
│   └── <PageName>.ts
├── fixtures/
│   └── index.ts              # All custom fixtures + re-export of expect
├── tests/                    # Test files only — no setup logic here
│   └── <feature>.spec.ts
├── test-data/                # Centralised test data — no magic strings in tests
│   └── users.ts
├── playwright.config.ts
└── tsconfig.json
```

---

## Step 1 — tsconfig.json

Create at project root if missing:

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "commonjs",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "types": ["node", "@playwright/test"]
  }
}
```

> `@types/node` must be installed for the `node` type to resolve. Run `npm i -D @types/node` if not already present.

---

## Step 2 — playwright.config.ts (key settings)

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  use: {
    baseURL: 'https://your-app-url.com', // ← set this
    trace: 'on-first-retry',
  },
});
```

---

## Step 3 — Page Object template (`pages/<PageName>.ts`)

```typescript
import { Page, Locator } from '@playwright/test';

export class <PageName> {
  readonly page: Page;

  // Declare one readonly Locator per interactive element
  readonly <elementName>: Locator;

  constructor(page: Page) {
    this.page = page;

    // Assign all locators here — never inside methods
    // Prefer data-test attributes: page.locator('[data-test="x"]')
    this.<elementName> = page.locator('[data-test="<selector>"]');
  }

  async goto() {
    await this.page.goto('/<route>');
  }

  async <actionMethod>() {
    // await every Playwright call
    await this.<elementName>.click();
  }

  // Synchronous getter — no async, just returns the locator for test assertions
  get<ElementName>() {
    return this.<elementName>;
  }
}
```

---

## Step 4 — Test data (`test-data/users.ts`)

```typescript
export type TUser = {
  username: string;
  password: string;
};

export const validStandardUser: TUser = {
  username: 'your_username',
  password: 'your_password',
};

export const invalidUser: TUser = {
  username: 'your_username',
  password: 'wrong_password',
};
```

---

## Step 5 — Fixtures (`fixtures/index.ts`)

```typescript
import { test as base } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { InventoryPage } from '../pages/InventoryPage';
import { validStandardUser } from '../test-data/users';

type MyFixtures = {
  loginPage: LoginPage;
  inventoryPage: InventoryPage; // example: already-logged-in fixture
};

export const test = base.extend<MyFixtures>({
  // Fixture: navigated to login page, not yet logged in
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await use(loginPage);
  },

  // Fixture: already logged in — test gets straight to asserting
  inventoryPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(validStandardUser);
    await use(new InventoryPage(page));
  },
});

// Re-export expect so tests only need one import
export { expect } from '@playwright/test';
```

---

## Step 6 — Test file (`tests/<feature>.spec.ts`)

```typescript
import { test, expect } from '../fixtures'; // ← always import from fixtures, not @playwright/test
import { invalidUser } from '../test-data/users';

// Tests should be pure assertions — no setup logic
test('page title is correct', async ({ inventoryPage }) => {
  await expect(inventoryPage.getTitle()).toHaveText('Expected Title');
});

test('error shown for invalid credentials', async ({ loginPage, page }) => {
  await loginPage.login(invalidUser);
  await expect(page.locator('[data-test="error"]')).toBeVisible();
  await expect(page).toHaveScreenshot('login-page-error-state.png'); // visual regression for error state
});

test('visual regression — inventory page', async ({ inventoryPage }) => {
  // Mask dynamic elements (e.g. copyright year) to prevent flaky diffs
  await expect(inventoryPage.page).toHaveScreenshot('inventory-page.png', {
    fullPage: true,
    mask: [inventoryPage.page.locator('[data-test="footer-copy"]')],
  });
});

test('visual regression — nav menu open', async ({ inventoryPage }) => {
  await inventoryPage.openMenu(); // trigger conditionally rendered element
  await expect(inventoryPage.logoutLink).toBeVisible();
  await expect(inventoryPage.page).toHaveScreenshot('inventory-page-menu-open.png', {
    fullPage: true,
    mask: [inventoryPage.page.locator('[data-test="footer-copy"]')],
  });
});
```

---

## Golden Rules (always apply)

| Rule                                        | Detail                                                                                                                                                                                                                                         |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Assertions in tests only                    | Never use `expect()` inside a Page Object                                                                                                                                                                                                      |
| `await` every Playwright call               | `.fill()`, `.click()`, `.goto()` are all async                                                                                                                                                                                                 |
| Only `async` when needed                    | Don't mark a method `async` if it has no `await`                                                                                                                                                                                               |
| Locators in constructor only                | Never define locators inside action methods                                                                                                                                                                                                    |
| One import source                           | Tests import `test` and `expect` from `../fixtures`, not `@playwright/test`                                                                                                                                                                    |
| No magic strings in tests                   | All selectors in Page Objects, all data in `test-data/`                                                                                                                                                                                        |
| Install `@types/node`                       | Always run `npm i -D @types/node` so Node globals resolve in TypeScript                                                                                                                                                                        |
| First run uses --update-snapshots           | Run `npx playwright test --update-snapshots` on the first run to create visual baselines; do not end the session until all tests pass                                                                                                          |
| Visual regression for error states          | Every error state test must include `await expect(page).toHaveScreenshot('<page>-error-state.png')` immediately after the error element is confirmed visible                                                                                   |
| Visual regression for conditional UI states | Every element revealed by user interaction (menu, modal, drawer, dropdown) needs its own test: trigger the interaction, assert the element is visible, then call `toHaveScreenshot` with a state-describing name (e.g. `<page>-menu-open.png`) |     | Mask dynamic elements | During exploration, identify elements with content that changes between runs (copyright year, timestamps, session data, third-party widgets). Pass them as `mask: [page.locator('...')]` in every `toHaveScreenshot` call where they appear. |
| Full-page screenshots                       | Always pass `fullPage: true` to every `toHaveScreenshot` call to capture content below the fold, not just the visible viewport.                                                                                                                |
| DRY — reuse existing Page Objects           | Before adding locators or methods to a new Page Object, read all existing `pages/*.ts` files. If the same selector string or action method already exists on another Page Object, import and reuse it via fixtures rather than duplicating it. |
