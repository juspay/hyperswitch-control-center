---
name: pr-review
description: Review a GitHub PR by fetching its diff, analyzing it with momus (expert reviewer), and producing structured inline comments with file paths, line numbers, and severity levels. MUST USE when the user shares a GitHub PR link and asks for a review, says "review this PR", "look at this pull request", "give me feedback on PR #123", or any variation of requesting code review on a pull request. Also trigger when the user pastes a GitHub PR URL even without explicitly saying "review".
---

# PR Review Skill

You review a GitHub PR end-to-end: fetch the diff, get expert analysis from momus, and post every review comment directly on the PR as inline GitHub comments. You do NOT stop after showing the summary — you MUST post the comments on GitHub before you are done.

## Workflow

### Step 1: Extract PR Information

Parse the PR identifier from the user's message:

- Full URL: `https://github.com/org/repo/pull/123` → extract number `123` and repo `org/repo`
- Short form: `PR #123` or `#123` → use number directly
- If just a number with no repo context, infer from `gh repo view --json nameWithOwner -q '.nameWithOwner'`

### Step 2: Fetch PR Diff and Metadata

Run these commands (use `--repo org/repo` if the PR is in a different repo):

```bash
gh pr view <NUMBER> --json title,body,baseRefName,headRefName,files,additions,deletions,changedFiles,headRefOid
gh pr diff <NUMBER>
gh pr diff <NUMBER> --stat
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

Save these for later — you need them to post comments:
- `PR_NUMBER` = the PR number
- `COMMIT_SHA` = `headRefOid` from the metadata
- `OWNER_REPO` = `nameWithOwner` (e.g. `juspay/hyperswitch-control-center`)

### Step 3: Send to Momus for Expert Review

Invoke momus synchronously (do NOT run in background — you need the result):

```
task(subagent_type="momus", run_in_background=false, load_skills=[], ...)
```

Prompt momus with:

```
Review the following GitHub Pull Request.

## PR Metadata
- Title: <title>
- Description: <body>
- Base: <baseRefName> → Head: <headRefName>
- Files changed: <changedFiles>, +<additions> -<deletions>

## Changed Files
<file list with stats>

## Full Diff
<complete diff>

## Instructions

For each issue found, return:
- file_path: exact relative path (e.g. src/components/Button.tsx)
- line_number: line in the NEW file (right side of diff, added/modified lines only)
- severity: critical | warning | suggestion | nitpick
- comment: clear, actionable description
- suggested_code: (optional) corrected snippet

Also return:
- summary: 2-3 sentence assessment
- verdict: approve | request_changes | comment_only

Return as JSON:
{
  "summary": "...",
  "verdict": "...",
  "comments": [
    { "file_path": "...", "line_number": N, "severity": "...", "comment": "...", "suggested_code": "..." }
  ]
}
```

### Step 4: Validate Momus Output

1. Parse the JSON from momus
2. Verify each comment has `file_path`, `line_number`, `severity`, `comment`
3. Drop comments referencing files not in the PR's changed files list
4. Sort by severity: critical → warning → suggestion → nitpick

### Step 5: Show Review Summary

Display to the user:

```
## PR Review: <title>

**Verdict**: <approve/request_changes/comment_only>
**Summary**: <summary>

### Critical (N)
- `file:line` — comment

### Warnings (N)
- `file:line` — comment

### Suggestions (N)
- `file:line` — comment

### Nitpicks (N)
- `file:line` — comment
```

### Step 6: Post All Comments on GitHub

THIS STEP IS NOT OPTIONAL. After showing the summary, you MUST post every comment on the PR. Do not ask the user for confirmation — just post them.

#### 6a. Validate lines are in the diff

For each comment, check the line is actually in the diff:

```bash
gh pr diff <PR_NUMBER> -- <FILE_PATH>
```

- Line appears as a `+` line on the right side → post as inline comment (Step 6b)
- Line is NOT in the diff → post as PR-level comment instead (Step 6c)

#### 6b. Post inline comments

Comment bodies often contain backticks, pipes, quotes, newlines, and code fences that WILL break shell parsing if passed as `-f body="..."`. You MUST write the JSON payload to a temp file and use `--input` to avoid parse errors.

For each comment, write a JSON file and post it:

```bash
# 1. Build the JSON payload and write to a temp file
cat > /tmp/pr_comment.json << 'JSONEOF'
{
  "body": "<COMMENT_BODY>",
  "commit_id": "<COMMIT_SHA>",
  "path": "<FILE_PATH>",
  "line": <LINE_NUMBER>,
  "side": "RIGHT"
}
JSONEOF

# 2. Post using --input to avoid shell escaping issues
gh api repos/<OWNER_REPO>/pulls/<PR_NUMBER>/comments \
  --method POST \
  --input /tmp/pr_comment.json
```

**Building the body string**: Construct `<COMMENT_BODY>` as a properly JSON-escaped string. Remember to escape:
- `"` → `\"`
- newlines → `\n`
- backslashes → `\\`
- tabs → `\t`

For a comment WITH `suggested_code`, the body should be:

```
**[<SEVERITY>]** <COMMENT>\n\n```suggestion\n<SUGGESTED_CODE>\n```
```

For a comment WITHOUT `suggested_code`, the body is simply:

```
**[<SEVERITY>]** <COMMENT>
```

**CRITICAL**: Always use the heredoc + `--input` pattern. NEVER pass the body as a `-f body="..."` argument — it will break on any comment containing backticks, pipes, or quotes.

#### 6c. Post PR-level comments

For comments where the line is NOT in the diff, or that have no file/line, also use a temp file:

```bash
cat > /tmp/pr_comment.json << 'JSONEOF'
{
  "body": "**[<SEVERITY>]** `<FILE_PATH>:<LINE_NUMBER>` — <COMMENT>"
}
JSONEOF

gh api repos/<OWNER_REPO>/issues/<PR_NUMBER>/comments \
  --method POST \
  --input /tmp/pr_comment.json
```

#### 6d. Post the overall review summary

After all inline comments are posted, post the verdict as a PR comment:

```bash
cat > /tmp/pr_comment.json << 'JSONEOF'
{
  "body": "## Review Summary\n\n**Verdict**: <VERDICT>\n\n<SUMMARY>\n\n---\n_Automated review via momus_"
}
JSONEOF

gh api repos/<OWNER_REPO>/issues/<PR_NUMBER>/comments \
  --method POST \
  --input /tmp/pr_comment.json
```

### Step 7: Report Results

After posting, show what happened:

```
## Comments Posted

### Inline Comments
- `src/Button.tsx:42` — "[critical] ..." ✓
- `src/helpers.js:15` — "[warning] ..." ✓

### PR-Level Comments
- Review summary ✓

### Downgraded (line not in diff)
- `src/client.ts:200` — posted as PR comment instead

### Failed
- `src/api.ts:30` — error: <reason>
```

If a comment fails to post, log the error and continue with the rest.

## Error Handling

- `gh` not authenticated → tell user to run `gh auth login`
- Invalid PR number or repo → report error clearly
- Momus returns unparseable response → show raw output, ask to retry
- Individual comment fails to post → log error, continue with remaining
- All comments fail → suggest checking GitHub permissions
- Very large PR (50+ files / 2000+ lines) → split into batches, tell the user

## Important

- Line numbers MUST be from the NEW file (right side of diff) — that's what GitHub expects
- `commit_id` MUST be `headRefOid` — not any other commit
- Preserve exact file paths from the diff — no normalizing
- Fetch the FULL diff, not just filenames — momus needs actual code to review
      
