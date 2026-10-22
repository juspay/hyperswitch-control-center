# Accordion migration checks

Run from the repository root, after `npm run re:build`, against an already-running
local dashboard. This configuration never starts a server or provisions accounts.

```sh
PLAYWRIGHT_BASE_URL=http://127.0.0.1:9100 \
PLAYWRIGHT_STORAGE_STATE=/absolute/path/to/storage-state.json \
PLAYWRIGHT_CHROMIUM_EXECUTABLE=/absolute/path/to/chromium \
ACCORDION_EVIDENCE_DIR=/absolute/path/outside/git \
npx playwright test -c playwright-tests/accordion/playwright.config.ts --repeat-each=2
```

Omit `ACCORDION_EVIDENCE_DIR` to skip screenshots. The live tests skip without a
storage-state path. Never commit authentication state or screenshot binaries.
Live screenshots crop to the Accordion, omit account metadata, and mask inputs.
Tracing, video, and automatic screenshots are disabled.

- Live sandbox reads: Payment settings > Webhook Configuration, desktop/mobile,
  v2 DOM marker, expansion, multi-open, Enter/Space, arrow-key focus, and width.
  No save/update buttons are activated; PUT/PATCH/DELETE requests are blocked.
- Synthetic page, fulfilled locally by Playwright: actual compiled adapter with
  single-open/initial state, callbacks, programmatic close, Blend-disabled path,
  and custom-header fallback. Disabled behavior uses an actual v2 item directly;
  the application Accordion record has no disabled field.
- No mutation/persistence or live connector credential/workflow coverage is claimed.
  Custom/interactive headers deliberately retain the existing application Accordion
  because v2 requires a string title and removes custom trigger support.
- Callback expectations retain existing semantics: switching the single-open item
  does not call the old item's collapse callback; programmatic close does not emit
  collapse callbacks.

The fixture bundles into a temporary directory outside git and removes it afterward.
It supplies the legacy `hidden` CSS utility, not the complete application stylesheet.
The parent repository's ESLint discovery can ignore nested worktrees. In that case:

```sh
npx eslint --no-ignore --resolve-plugins-relative-to "$PWD" playwright-tests/accordion/accordion.spec.ts playwright-tests/accordion/playwright.config.ts playwright-tests/accordion/fixture.js
npx prettier --check playwright-tests/accordion/*
```
