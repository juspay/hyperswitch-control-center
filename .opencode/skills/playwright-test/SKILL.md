---
name: playwright-test
description: Playwright E2E test automation — generates, runs, and heals tests. Triggers on "generate playwright tests", "create playwright tests", "run playwright tests", "write test", "write tests", "write test for", "write tests for", "create tests for", "test PR", "test module", "e2e test", "end-to-end test", "plan tests", "create test plan", "heal tests", "fix failing tests", "fix tests", "repair tests", "debug playwright", "test scenario", "test tag", "playwright test flow".
---

# Playwright Test Automation

**READ `orchestrator.md` and EXECUTE its instructions. You ARE the orchestrator.**

## Execution Modes

| Mode          | Triggers                                                                   | Pipeline                                              |
| ------------- | -------------------------------------------------------------------------- | ----------------------------------------------------- |
| **full**      | "generate tests", "write test(s)", "write test(s) for X", "create tests for X", "test PR #N" | Parse → Setup → Plan → Generate → Run → Heal → Report |
| **plan-only** | "plan tests", "create test plan"                                           | Parse → Setup → Plan → Report                         |
| **heal-only** | "fix tests", "heal tests", "repair tests", "fix failing tests"             | Parse → Setup → Run → Heal → Report                   |

## State Machine

Every step MUST read `session.json`, validate the transition, and write the new status BEFORE executing.

```
initialized → server-ready → planning → planning-complete → generating
→ generating-complete → running → all-pass|some-pass|none-pass
→ [healing] → complete
```

## Session Directory

`.opencode/sessions/playwright-run/` — contains:
`input-context.json`, `session.json`, `test-plan.json`, `run-results.json`, `bug-report.md`, `summary.json`

## Module Prerequisites (Generic Discovery)

**Rule:** ALWAYS search `playwright-tests/e2e/` for existing tests matching the target module FIRST. Copy their `beforeEach`/`beforeAll` exactly. Fall back to this table ONLY if no existing test covers the module.

| Module           | API Setup Chain (from commands.ts)                              | URL                       |
| ---------------- | --------------------------------------------------------------- | ------------------------- |
| auth             | None (tests create users inline)                                | /dashboard/login          |
| home             | signupUser → loginUI                                            | /dashboard/home           |
| payments         | signupUser → loginUser → createDummyConnectorAPI → createPaymentAPI | /dashboard/payments    |
| refunds          | Same as payments                                                | /dashboard/refunds        |
| disputes         | Same as payments                                                | /dashboard/disputes       |
| connectors       | signupUser → loginUI                                            | /dashboard/connectors     |
| payoutConnectors | signupUser → loginUI                                            | /dashboard/payout-connectors |
| routing          | signupUser → loginUser → createDummyConnectorAPI                | /dashboard/routing        |
| analytics        | signupUser → loginUI                                            | /dashboard/analytics      |
| users            | signupUser → loginUI (invite user in test body)                 | /dashboard/users          |
| settings         | signupUser → loginUI                                            | /dashboard/settings       |

**For any unlisted module:** read the closest existing test, extract its setup chain, and adapt. The pattern is always: create user → authenticate → create dependencies → test.

## Selector Priority

1. `[data-testid="X"]` — primary
2. `[data-button-for="X"]` — buttons
3. `getByPlaceholder("X")` — form inputs
4. `getByText("X", { exact: true })` — visible text
5. `getByRole("X", { name: /pattern/i })` — semantic
6. `[data-table-location="X"]` — table cells
7. `[name="X"]` — named form inputs

**AVOID:** class-based selectors, nth-child, deep CSS paths.

## Page Objects (Reuse First)

| Page Object        | Path                                              |
| ------------------ | ------------------------------------------------- |
| SignInPage          | support/pages/auth/SignInPage.ts                  |
| SignUpPage          | support/pages/auth/SignUpPage.ts                  |
| HomePage            | support/pages/homepage/HomePage.ts                |
| PaymentOperations   | support/pages/operations/PaymentOperations.ts     |
| PaymentConnector    | support/pages/connector/PaymentConnector.ts       |
| PaymentSettings     | support/pages/developers/PaymentSettings.ts       |
| PaymentRouting      | support/pages/workflow/paymentRouting/PaymentRouting.ts |

## API Helpers (commands.ts)

```
signupUser(email, password, context?)           → void
loginUser(email, password, context?)            → { token, merchantId }
loginUI(page, name?, pass?)                     → void (UI login + 2FA skip)
createDummyConnectorAPI(merchantId, label, ctx?) → void
createPaymentAPI(merchantId, ctx?)              → { payment_id }
createAPIKey(merchantId, token, ctx?)           → apiKey string
deleteConnector(mcaId, merchantId, token, ctx?) → void
ompLineage(page)                                → { orgId, merchantId, profileId }
```

Utilities: `generateUniqueEmail()`, `generateDateTimeString()`

## Browser Auth for Sub-Agent Exploration (Skip 2FA)

Every sub-agent that uses browser tools MUST follow this exact sequence:

```
1. browser_navigate → http://localhost:9000/dashboard/login
2. browser_snapshot → check current URL
3. IF URL contains /home or /dashboard (not /login):
   → Sign out: browser_navigate to /dashboard/login?force=true
   OR click profile → sign out
4. Create temp user via bash:
   curl -s -X POST http://localhost:8080/user/signup_with_merchant_id \
     -H "Content-Type: application/json" -H "api-key: test_admin" \
     -d '{"email":"explore_$(date +%s)@test.com","password":"Playwright00#","company_name":"Explore_$(date +%s)","name":"Explorer"}'
5. browser_snapshot → find email/password fields → browser_type credentials
6. browser_click [data-button-for="continue"] or submit button
7. browser_snapshot → if "Skip now" or 2FA prompt visible → browser_click "Skip now"
8. Verify URL is /dashboard/home
9. MUST call browser_close when ALL exploration/debugging is complete
```

## File Naming

| Source   | Pattern                  | Example                       |
| -------- | ------------------------ | ----------------------------- |
| PR       | `PR-{N}-{slug}.spec.ts` | `PR-123-payment-form.spec.ts` |
| Module   | `module-{name}.spec.ts`  | `module-auth.spec.ts`         |
| Scenario | `scenario-{slug}.spec.ts`| `scenario-checkout.spec.ts`   |
| Tag      | `tag-{name}.spec.ts`     | `tag-payment-flow.spec.ts`    |

## Graceful Server Shutdown

```bash
# Frontend (SIGTERM first, SIGKILL fallback after 5s)
lsof -ti:9000 | xargs -r kill -TERM 2>/dev/null; sleep 5; lsof -ti:9000 | xargs -r kill -9 2>/dev/null
```

## Environment

- Frontend: http://localhost:9000 | Backend: http://localhost:8080 | Mail: http://localhost:8025
- Password: `PLAYWRIGHT_PASSWORD` env or `Playwright00#`

## Next Step

Read `orchestrator.md` and execute it. You ARE the orchestrator. Delegate via task(). Present final report and STOP.
