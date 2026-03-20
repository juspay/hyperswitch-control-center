---
name: add-connector
description: Add a new connector (processor, payout, 3DS, FRM, PM auth, tax, billing, vault) to the control center. Use when the user wants to add, register, or integrate a new connector, payment processor, or gateway. Triggers on phrases like "add a connector", "new processor", "integrate a gateway", "add payout connector".
---

You are helping the user add a new connector to the hyperswitch control center using the automated script at `scripts/add-connector.mjs`.

## Step 1: Gather inputs

Ask the user for the following information. Present them as a numbered list and let the user answer all at once or one at a time.

1. **Category** — one of: `processor`, `payout`, `threeds`, `frm`, `pmauth`, `tax`, `billing`, `vault` (default: `processor`)
2. **Connector name** — lowercase identifier, e.g. `revolv3`
3. **Display name** — UI label, e.g. `Revolv3`
4. **Enum name** — uppercase variant for the ReScript enum (default: name in UPPER_CASE)
5. **Description** — one-line description of the connector
6. **SVG path** — optional path to an SVG icon file (leave blank to skip)
7. **Add to live list** — `y` or `n` (only relevant for categories that have a live list; default: `n`)

If the user already provided some of these values, skip those questions and confirm what you have.

## Step 2: Run the script

Build and run the command:

```bash
node scripts/add-connector.mjs \
  --category <category> \
  --name <name> \
  --display "<display_name>" \
  --enum <ENUM_NAME> \
  --description "<description>" \
  [--svg <path>] \
  [--live true|false]
```

Omit `--svg` if no path was provided. Set `--live true` only if the user said yes.

## Step 3: Show results

After the script completes successfully:

- Print a summary of what was added
- Suggest running `npm run re:build` to verify the changes compile correctly

If the script fails, show the error output and help the user fix the issue.

## Step 4: Ensure dev environment is running

Before verifying in the browser, make sure the local environment is ready.

### 4a: Set webpack proxy to integ

Check `webpack.dev.js` line ~19. The API proxy target must point to `https://integ.hyperswitch.io/api`. If it points somewhere else, update it:

```bash
# Check current target
grep -n 'target:' webpack.dev.js | head -5
```

If the `/api` proxy target is not `https://integ.hyperswitch.io/api`, edit `webpack.dev.js` to set it. This ensures the dashboard at `localhost:9000` talks to the integ backend.

### 4b: Start ReScript compiler (if not running)

```bash
# Check if re:start is already running
pgrep -f "re:start" > /dev/null && echo "rescript running" || echo "rescript not running"
```

If not running, start it in the background:

```bash
npm run re:start &
```

Wait a few seconds for it to compile.

### 4c: Start dev server (if not running)

```bash
# Check if localhost:9000 is responding
curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 2>/dev/null || echo "not running"
```

If not running, start it in the background:

```bash
npm start &
```

Wait for it to be ready (poll `http://localhost:9000` until it responds, timeout 60s).

## Step 5: Verify in Dashboard (Playwright)

After the environment is ready, verify the connector appears in the dashboard UI.

### 5a: Get credentials

Check the **Credentials** section at the bottom of this file. If values are filled in (not `(not set)`), use them. Otherwise ask the user for:

1. **Dashboard URL** (default: `http://localhost:9000`)
2. **Email**
3. **Password**

Once provided, update the Credentials section in this skill file so they persist for future runs.

### 5b: Login and screenshot

Use the inbuilt `/playwright` skill:

```
skill(
  name="playwright",
  user_message="""
  1. Navigate to <dashboard_url>/dashboard/login
  2. Fill the email input field with <email>
  3. Fill the password input field with <password>
  4. Click the sign-in / login button
  5. Wait for navigation to complete (networkidle)
  6. Navigate to <dashboard_url>/connectors
  7. Take full-page screenshot to: .opencode/add-connector/screenshot_<connector_name>.png
  8. Check if text "<display_name>" is visible on the page

  Return JSON with passed status, screenshot path, and assertion results.
  """
)
```

### 5c: Report

- If verification passed: show screenshot path and confirm connector is visible in the UI
- If verification failed: show the error, suggest the user check manually — the code changes are still valid

---

## Credentials

> These are saved by the skill for reuse. Update manually or let the skill fill them in.

- **Dashboard URL**: (not set)
- **Email**: (not set)
- **Password**: (not set)
