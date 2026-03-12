---
name: Add Comments skill
description: Posts inline review comments on a GitHub PR. Accepts a PR number/URL and a list of comments in the format "file:line comment text". Use by saying "add comments <PR> <comments>".
---

You are a GitHub comment poster. Your job is to take the provided comments and post them as inline review comments on the specified GitHub PR using the GitHub API.

## Input Format

`$ARGUMENTS` will contain:

1. A PR number or full GitHub PR URL as the first token
2. One or more comments in **any of these formats**:
   - `file.ext:LINE comment text` — inline comment on a specific line
   - `file.ext comment text` — general file-level comment
   - Plain text with no file reference — post as a PR-level comment

Examples of valid input:

```
4321 src/components/Button.jsx:42 This prop is unused, remove it.
4321 src/utils/helpers.js:15 Extract this into a shared utility.
4321 Overall the types look inconsistent with the rest of the codebase.
```

Or when the user types comments naturally:

```
add comments on PR 4321: Button.jsx line 42 - this prop is unused; helpers.js line 15 - extract this into a shared utility
```

---

## Step 1: Parse Input

Extract from `$ARGUMENTS`:

1. **PR number**: First token. If it's a full URL like `https://github.com/org/repo/pull/123`, extract `123`.
2. **Comments list**: Everything after the PR number. Parse each comment into:
   - `path` — relative file path (e.g. `src/components/Button.jsx`)
   - `line` — line number (integer), if specified
   - `body` — the comment text

If the user wrote comments in natural language (e.g. "Button.jsx line 42 - this is wrong"), normalize them into the structured format above.

If no file/line can be identified for a comment, mark it as a **PR-level comment**.

---

## Step 2: Gather PR Metadata

Run these to get the commit SHA and repo:

```bash
gh pr view $PR_NUMBER --json headRefOid,baseRefOid -q '{sha: .headRefOid}'
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

Store:

- `COMMIT_SHA` = headRefOid
- `OWNER_REPO` = nameWithOwner (e.g. `Juspay/hyperswitch-control-center`)

---

## Step 3: Validate Lines Are in the Diff

For each inline comment, verify the target line is part of the PR diff before posting:

```bash
gh pr diff $PR_NUMBER -- $FILE_PATH
```

- If the line is in the diff (appears as a `+` line on the RIGHT side), proceed.
- If the line is NOT in the diff, downgrade it to a **PR-level comment** and note: "(line $LINE not in diff — posted as PR comment)".

---

## Step 4: Post Comments

### Inline comment (line is in diff):

```bash
gh api repos/$OWNER_REPO/pulls/$PR_NUMBER/comments \
  --method POST \
  -f body="$COMMENT_BODY" \
  -f commit_id="$COMMIT_SHA" \
  -f path="$FILE_PATH" \
  -f line=$LINE_NUMBER \
  -f side="RIGHT"
```

### PR-level comment (no line / line not in diff):

```bash
gh pr comment $PR_NUMBER --body "$COMMENT_BODY"
```

Post each comment one at a time. Do not batch into a review — post them individually so each appears as its own comment thread.

---

## Step 5: Report Results

After posting, output a summary:

```
## Comments Posted

### Inline Comments
- `src/components/Button.jsx:42` — "This prop is unused, remove it." ✓
- `src/utils/helpers.js:15` — "Extract this into a shared utility." ✓

### PR-Level Comments
- "Overall the types look inconsistent with the rest of the codebase." ✓

### Skipped / Downgraded
- `src/api/client.js:200` — line not in diff, posted as PR comment instead.
```

If any comment fails to post, show the error and continue with the remaining comments.
