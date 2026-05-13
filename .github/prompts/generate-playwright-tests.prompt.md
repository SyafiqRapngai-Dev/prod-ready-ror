---
description: 'Generate a full Playwright test suite for a single URL, or for an entire RoR app via config/routes.rb. Explores pages, captures screenshots, detects login flows, and produces Page Objects, fixtures, and spec files.'
agent: playwright-orchestrator
argument-hint: 'Either (a) a single URL (e.g. https://example.com/login), or (b) a path to config/routes.rb and a base URL (e.g. "config/routes.rb — base URL: http://localhost:3000")'
---

Generate a complete Playwright test suite for the following input:

{{input}}

Orchestrate the full pipeline:

**If the input is a single URL:**

1. Use `playwright-explorer` to explore the URL, capture all interactive states and screenshots, detect login flows, and write a discovery report to `e2e/docs/`.
2. Use `playwright-test-generator` to read the discovery report and generate all code files (Page Objects, fixtures, test data, spec files), then run `cd e2e && npx playwright test --update-snapshots` until the full suite is green.

**If the input is a path to `config/routes.rb` and a base URL:**

1. Read `config/routes.rb`, extract all `GET` HTML routes, identify the auth route, classify public vs. authenticated routes, and present the confirmed URL queue to the user before proceeding.
2. Once the URL queue is confirmed, create `e2e/docs/routes.md` as a to-do checklist of all confirmed routes (unchecked). Update each entry to checked as its tests are generated and green.
3. For each URL in the confirmed queue, use `playwright-explorer` to explore the page and write a discovery report to `e2e/docs/`. Process the auth route first. Continue on individual failures — do not stop the entire batch.
4. For each successfully created discovery report, use `playwright-test-generator` to generate the full test suite and run `cd e2e && npx playwright test --update-snapshots` until green.

Do not proceed to generation if a discovery report was not successfully created for a given URL.
