---
name: ui-bug-fix
description: Fix UI bugs through an analyze-fix-verify iteration loop. Takes a natural language bug description (e.g., "login button is misaligned", "modal doesn't close on Escape"), identifies affected files, generates code fixes, verifies with Playwright browser automation, and iterates until fixed or max attempts. Use this skill whenever the user mentions a UI bug, visual issue, layout problem, or component not working correctly. Triggers on "fix UI bug", "ui bug", "fix the bug", "button is broken", "modal not working", etc.
---

# UI Bug Fix Skill

Fix UI bugs autonomously through an iterative analyze-fix-verify loop.

## Workflow Overview

```
Bug Description → Analysis → Code Fix → Verification → (Iterate if needed)
```

## Step-by-Step Process

### Step 1: Parse the Bug Description

Extract from user's message:

- The bug description (what's wrong)
- Any specific component names mentioned
- Browser/context if provided

Example inputs:

- "Login button is misaligned to the right"
- "Modal doesn't close when I press Escape"
- "Loading spinner is too small"

### Step 2: Analyze the Bug

Use your understanding of the codebase to:

1. **Identify bug type**:
   - `css`: Styling issues (alignment, colors, spacing)
   - `layout`: Position, flex/grid issues
   - `interaction`: Click handlers, events
   - `visual`: Visibility, animations
   - `react_component`: Component logic/props

2. **Find affected files**:
   - Search for components mentioned in bug description
   - Look for related CSS/styled-components files
   - Check for parent containers that might affect layout

3. **Determine verification strategy**:
   - Screenshot comparison (for visual bugs)
   - DOM assertion (element exists, has correct properties)
   - Interaction test (click, keypress works)

Output analysis as JSON:

```json
{
  "bug_type": "css",
  "affected_files": ["src/components/LoginButton.tsx", "src/styles/login.css"],
  "description": "Button has incorrect margin-right causing misalignment",
  "verification": {
    "type": "screenshot",
    "url": "http://localhost:9000/login",
    "assertions": [
      {
        "type": "css",
        "selector": "[data-testid='login-button']",
        "property": "margin-right",
        "expected": "0px"
      }
    ]
  },
  "confidence": 0.8
}
```

### Step 3: Generate Code Fix

For each affected file:

1. Read current file content
2. Identify the specific code causing the issue
3. Generate the fix
4. Create a unified diff showing before/after

Example fix for CSS alignment:

```diff
--- a/src/components/LoginButton.tsx
+++ b/src/components/LoginButton.tsx
@@ -10,7 +10,7 @@ const LoginButton = styled.button`
   background: #0066cc;
   color: white;
   border: none;
-  margin-right: 20px;
+  margin-right: 0;
   cursor: pointer;
 `;
```

### Step 4: Get User Confirmation

Present to user:

````
## Bug Analysis

**Type**: CSS alignment issue
**Files to modify**:
  - src/components/LoginButton.tsx

**Description**: Button has incorrect margin-right of 20px causing right-side gap

## Proposed Fix

```diff
[show diff]
```

**Apply this fix?** (y/n)

````

Wait for user response. If 'n', ask what they'd like to change or abort.

### Step 5: Apply the Fix

If user confirms:

1. Apply the diff to files
2. Create state tracking file:
   ```bash
   mkdir -p .opencode/ui-bug-fix
   cat > .opencode/ui-bug-fix/state.json << 'EOF'
   {
     "bug_description": "...",
     "iteration": 1,
     "max_iterations": 5,
     "files_changed": ["src/components/LoginButton.tsx"],
     "attempts": []
   }
    EOF
   ```

### Step 6: Start Dev Server (if needed)

Check if dev server is running:

```bash
curl -s http://localhost:9000 > /dev/null && echo "running" || echo "stopped"
```

If stopped:

1. Find available port (default 9000, fallback to 9001, 9002...)
2. Start server: `npm run start &`
3. Wait for ready (health check or timeout 60s)
4. Record server PID for cleanup

### Step 7: Verify Fix with Playwright

Invoke the playwright-verifier agent:

```
task(
  subagent_type="playwright-verifier",
  run_in_background=false,
  load_skills=["playwright"],
  prompt="""
  Verify this UI bug fix:

  URL: http://localhost:9000/login
  Bug: Login button is misaligned

  Check:
  1. Navigate to URL
  2. Screenshot full page to: .opencode/ui-bug-fix/screenshot_1.png
  3. Verify button with selector [data-testid='login-button'] has margin-right: 0px
  4. Check console for errors

  Return JSON with passed status, screenshot path, and assertion results.
  """
)
```

### Step 8: Evaluate and Iterate

Parse the verifier response:

**If verification passed**:

- Success! Report to user
- Show before/after screenshots if available
- Go to Step 9 (Cleanup)

**If verification failed and iterations < 5**:

1. Read the failure reason
2. Analyze why the fix didn't work
3. Update state.json with attempt details
4. Increment iteration counter
5. Go back to Step 3 (generate new fix)

**If max iterations (5) reached**:

- Report failure to user
- Show all attempts made
- Offer to try different approach or abort
- Go to Step 9 (Cleanup)

### Step 9: Cleanup (Always Runs)

Regardless of success or failure:

1. **Stop dev server** (if we started it):

   ```bash
   kill $SERVER_PID 2>/dev/null
   ```

2. **Preserve evidence**:
   - Screenshots are already saved
   - State file has complete history
   - Create summary report:

   ```bash
   cat > .opencode/ui-bug-fix/report.md << 'EOF'
   # UI Bug Fix Report

   **Bug**: [description]
   **Status**: [success/failed]
   **Iterations**: N/5
   **Files Changed**: [...]

   ## Attempts
   [list each attempt with result]

   ## Evidence
   - Screenshots: .opencode/ui-bug-fix/screenshot_*.png
   - State: .opencode/ui-bug-fix/state.json
   EOF
   ```

3. **Final report to user**:

   ```
   ## UI Bug Fix Complete

   **Status**: ✅ Fixed / ❌ Failed (max attempts reached)
   **Iterations**: 2/5
   **Final fix applied to**:
     - src/components/LoginButton.tsx

   **Verification**: Screenshot shows button properly aligned

   **Evidence saved to**: .opencode/ui-bug-fix/
   ```

## State Tracking

Maintain iteration state in `.opencode/ui-bug-fix/state.json`:

```json
{
  "bug_id": "uuid",
  "bug_description": "Login button is misaligned",
  "start_time": "2024-01-15T10:30:00Z",
  "iteration": 2,
  "max_iterations": 5,
  "status": "in_progress",
  "files_changed": ["src/components/LoginButton.tsx"],
  "attempts": [
    {
      "iteration": 1,
      "fix_summary": "Removed margin-right from button",
      "verification_passed": false,
      "failure_reason": "Button still has gap, padding also needs adjustment",
      "screenshot": ".opencode/ui-bug-fix/screenshot_1.png",
      "timestamp": "2024-01-15T10:31:00Z"
    }
  ]
}
```

## Cycle Detection

Prevent infinite loops by detecting oscillating fixes:

Before generating a new fix:

1. Calculate hash of current file state
2. Compare to hashes from previous attempts
3. If hash matches any previous attempt → abort with cycle detected
4. Otherwise, proceed with new fix

## Error Handling

- **Analysis fails** (can't identify files): Ask user for clarification
- **Server won't start**: Report error, preserve changes, abort
- **Verifier agent fails**: Retry once, then report error
- **User rejects fix**: Ask what to change or offer to abort
- **No improvement after 5 iterations**: Report failure, preserve evidence

## Example Usage

**User**: "The login button on the auth page is way off to the right"

**Skill workflow**:

1. Parse: "login button", "auth page", "off to the right" (alignment issue)
2. Analyze: Find LoginButton component, check CSS, identify margin-right issue
3. Generate fix: Remove margin-right from button styles
4. Show diff, get user confirmation
5. Apply fix
6. Start dev server on localhost:9000
7. Verify: Playwright checks button alignment, captures screenshot
8. Success: Button is aligned, report complete
9. Cleanup: Stop server, save report

## Limitations

- **UI bugs only**: Does not fix backend/API issues
- **Single page apps**: Assumes React/Vue/Angular style frontend
- **Local dev server**: Requires dev server to be startable
- **5 iteration max**: Prevents infinite loops
- **Manual confirmation**: Requires user approval before each code change
