---
name: raise-pr
description: End-to-end PR workflow for the hyperswitch-control-center repo. Use this skill whenever the user wants to raise a PR, submit changes, open a pull request, commit and push, or ship their work. Triggers on phrases like "raise a PR", "open a PR", "submit my changes", "commit and push", "ship this", "create a pull request". Even if the user just says "PR please" or "push my changes", use this skill.
---

You are running an end-to-end PR workflow for the hyperswitch-control-center repo. Walk through each step below, printing a clear status update before and after every action.

## Step 0: Assess current state

Run `git status` and `git diff --stat` to understand what's changed. Print a summary:

```
=== Current Changes ===
<list of modified/new/deleted files>
```

If there are no changes at all, stop and tell the user: "No changes detected. Nothing to commit."

---

## Step 1: Format code

Print: `[1/5] Running formatter (npm run re:format)...`

Run:
```bash
npm run re:format
```

- If it **succeeds**: print `✓ Formatting passed`
- If it **fails**: print the error output, then stop with:
  ```
  ✗ Formatting failed. Fix the errors above before raising a PR.
  ```

After formatting succeeds, check if `re:format` modified any files (`git diff --name-only`). If it did, print: `  → Formatter made changes to: <list of files>` — these will be included in the commit.

---

## Step 2: Lint

Print: `[2/5] Running linter (npm run lint:hooks)...`

Run:
```bash
npm run lint:hooks
```

- If it **succeeds**: print `✓ Lint passed`
- If it **fails**: print the full lint output so the user can see exactly which rules and files failed, then stop with:
  ```
  ✗ Lint failed. Fix the errors above before raising a PR.
  (Tip: run `npm run lint:hooks` locally to reproduce)
  ```

Do not proceed past this point if lint fails.

---

## Step 3: Commit

Print: `[3/5] Preparing commit...`

### 3a: Stage changes

Run `git diff --name-only` and `git status --short` to see what will be staged.

**Protected files — never stage these unless the user explicitly asks:**
- `config.toml` (contains local environment config that varies per developer)
- `webpack.dev.js` / `webpack.dev.ts` / any file matching `webpack.dev*` (local dev overrides)

Before staging, check if any of these files appear in the diff. If they do, warn the user:
```
⚠ Skipping protected files (not staging):
  - config.toml
  - webpack.dev.js
These contain local config and are excluded by default. Say "include config.toml" or "include webpack.dev" if you want them staged.
```

Stage everything except protected files:
```bash
git add -A
git restore --staged config.toml webpack.dev.js webpack.dev.ts  # unstage if accidentally staged
```
(Only run `git restore --staged` for files that are actually present/staged.)

### 3b: Generate commit message

Look at the staged diff (`git diff --cached --stat` and `git diff --cached`) to understand what changed. Draft a conventional commit message following this repo's style:

- `fix: <description>` for bug fixes
- `feat: <description>` for new features
- `chore: <description>` for tooling / non-functional changes
- `refactor: <description>` for refactors

Show the user the proposed commit message and ask them to confirm or edit it:

```
Proposed commit message:
  <message>

Press Enter to use this, or type a new message:
```

Wait for the user's response. Use their message if they provide one, otherwise use the proposed message.

### 3c: Create commit

```bash
git commit -m "<confirmed message>"
```

Print: `✓ Committed: <message>`

If the commit is rejected by a pre-commit hook, print the hook output clearly and stop:
```
✗ Pre-commit hook failed. See output above.
```

---

## Step 4: Select PR template

Print: `[4/5] Selecting PR template...`

Auto-detect the PR type based on the changes:
- If files related to a **connector** were modified (paths containing `connector`, `Connector`, or file names matching connector patterns): suggest **connector_addition**
- If the commit message starts with `fix:` or the changes are clearly bug fixes: suggest **bug_report**
- If the commit message starts with `feat:` or changes add new functionality: suggest **feature_request**

Present the options to the user:

```
Detected change type: <type> → suggesting template: <template>

Available PR templates:
  1. bug_report       — Submit a bug fix
  2. feature_request  — Submit a new feature
  3. connector_addition — Integrate a new connector

Which template? [1/2/3, or press Enter for <suggested>]:
```

Wait for their selection. Use the default if they just press Enter.

### Fill in the PR body

Based on the chosen template, ask for the relevant fields. Be concise — ask all required fields in one message. Examples:

**bug_report:**
```
For the bug report PR, I need:
- Bug description:
- Expected behavior:
- Actual behavior:
- Steps to reproduce:
```

**feature_request:**
```
For the feature request PR, I need:
- Feature description:
- Possible implementation approach:
```

**connector_addition:**
```
For the connector PR, I need:
- Connector name:
- Connector category (e.g. Payment Processor):
- Connector description:
```

Construct a well-formatted PR body from their answers. Include a ## Test Plan section at the end where you list likely manual test steps based on the changes.

---

## Step 5: Push and raise PR

Print: `[5/5] Pushing branch and creating PR...`

### 5a: Push

```bash
git push -u origin HEAD
```

If push fails (e.g. protected branch, no remote), print the error and stop with guidance.

### 5b: Create PR

```bash
gh pr create \
  --title "<commit message or user-supplied title>" \
  --body "<constructed body from template>" \
  --base main
```

If the user wants to target a different base branch, ask before pushing.

- If creation **succeeds**: print the PR URL clearly:
  ```
  ✓ PR raised successfully!
  → <PR URL>
  ```
- If creation **fails**: print the `gh` error output and stop.

---

## Final summary

After all steps complete successfully, print:

```
=== Done! ===
✓ Formatted
✓ Linted
✓ Committed: <message>
✓ PR raised: <URL>
```

If any step failed earlier, you would have already stopped and reported the error — no need to summarize failures here.
