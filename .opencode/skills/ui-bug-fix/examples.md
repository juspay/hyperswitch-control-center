# UI Bug Fix Skill - Examples

This document provides example scenarios showing how to use the `ui-bug-fix` skill.

## Invocation

To use the skill, simply describe the UI bug in natural language:

```
/ui-bug-fix "the login button is misaligned to the right"
```

Or:

```
/ui-bug-fix modal doesn't close when I press Escape key
```

## Example 1: CSS Alignment Bug

### Bug Description

**User says**: "The login button on the auth page is way off to the right"

### Expected Workflow

1. **Parse**: Extract "login button", "auth page", "off to the right"
2. **Analyze**:
   - Bug type: `css`
   - Affected files: `src/components/LoginButton.tsx`, `src/styles/login.css`
   - Issue: Incorrect margin-right causing right-side gap
3. **Generate Fix**:
   ```diff
   -  margin-right: 20px;
   +  margin-right: 0;
   ```
4. **Confirmation**: Show diff to user, wait for approval
5. **Apply**: Modify the CSS/TSX file
6. **Start Server**: Ensure dev server running on localhost:9000
7. **Verify**: Playwright captures screenshot, checks button position
8. **Result**: ✅ Button aligned correctly
9. **Cleanup**: Stop server, save report

### Expected Output

```
## UI Bug Fix Complete

**Status**: ✅ Fixed
**Iterations**: 1/5
**Final fix applied to**:
  - src/components/LoginButton.tsx

**Verification**: Screenshot shows button properly aligned
**Evidence saved to**: .opencode/ui-bug-fix/
```

---

## Example 2: Interaction Bug

### Bug Description

**User says**: "The modal dialog doesn't close when I press Escape"

### Expected Workflow

1. **Parse**: Extract "modal", "doesn't close", "press Escape"
2. **Analyze**:
   - Bug type: `interaction`
   - Affected files: `src/components/Modal.tsx`
   - Issue: Missing keyboard event handler for Escape key
3. **Generate Fix**:
   ```diff
   +  useEffect(() => {
   +    const handleEscape = (e: KeyboardEvent) => {
   +      if (e.key === 'Escape') onClose();
   +    };
   +    document.addEventListener('keydown', handleEscape);
   +    return () => document.removeEventListener('keydown', handleEscape);
   +  }, [onClose]);
   ```
4. **Confirmation**: Show code addition to user
5. **Apply**: Add the useEffect hook
6. **Start Server**: Ensure dev server running
7. **Verify**: Playwright opens modal, presses Escape, checks if closed
8. **Result**: ✅ Modal closes on Escape
9. **Cleanup**: Stop server, save report

### Expected Output

```
## UI Bug Fix Complete

**Status**: ✅ Fixed
**Iterations**: 1/5
**Final fix applied to**:
  - src/components/Modal.tsx

**Verification**: Playwright confirmed modal closes on Escape key
**Evidence saved to**: .opencode/ui-bug-fix/
```

---

## Example 3: Visual Bug (Multiple Iterations)

### Bug Description

**User says**: "Loading spinner is too small and barely visible"

### Expected Workflow

**Iteration 1:**

1. **Analyze**: Bug type `visual`, file `src/components/Spinner.tsx`
2. **Fix**: Increase font-size from 12px to 16px
3. **Verify**: ❌ Still too small
4. **Record**: First attempt failed

**Iteration 2:**

1. **Analyze**: Review feedback - needs to be larger
2. **Fix**: Increase to 24px with better contrast
3. **Verify**: ✅ Spinner visible and properly sized
4. **Complete**: Success on second attempt

### Expected Output

```
## UI Bug Fix Complete

**Status**: ✅ Fixed
**Iterations**: 2/5

**Attempt 1**: Increased to 16px - ❌ Still too small
**Attempt 2**: Increased to 24px with contrast fix - ✅ Perfect

**Final fix applied to**:
  - src/components/Spinner.tsx

**Verification**: Screenshot shows properly sized spinner
**Evidence saved to**: .opencode/ui-bug-fix/
```

---

## Example 4: Layout Bug (Failed After Max Attempts)

### Bug Description

**User says**: "The sidebar layout breaks on mobile view"

### Expected Workflow

**Iterations 1-5**: Various attempts to fix responsive layout

- Adjust flex properties
- Modify media queries
- Change grid layout
- Tweak container widths
- Fix overflow settings

**Result**: None fully resolve the issue due to complex nested layout

### Expected Output

```
## UI Bug Fix Complete

**Status**: ❌ Failed (max attempts reached)
**Iterations**: 5/5

All attempts documented in .opencode/ui-bug-fix/state.json

**Issue**: Layout complexity requires manual refactoring
**Recommendation**: Consider restructuring the component hierarchy

**Evidence saved to**: .opencode/ui-bug-fix/
```

---

## Common Bug Types

### CSS Issues

- Misaligned elements
- Wrong colors or spacing
- Font size problems
- Border/shadow issues

### Layout Issues

- Flex/Grid not working
- Responsive design problems
- Overflow/clipping issues
- Z-index stacking problems

### Interaction Issues

- Click handlers not working
- Keyboard events missing
- Focus management issues
- Hover states broken

### Visual Issues

- Elements not visible
- Animation problems
- Loading states missing
- Icon/image display issues

---

## Tips for Best Results

1. **Be specific**: "Login button is 20px too far right" is better than "button looks wrong"
2. **Mention component names**: Helps identify affected files quickly
3. **Describe expected behavior**: "Should close on Escape" clarifies the fix
4. **Review before applying**: Always check the diff before confirming
5. **Check evidence**: Review screenshots in `.opencode/ui-bug-fix/` after completion

---

## Troubleshooting

### Skill doesn't trigger

- Try alternative phrasing: "fix the UI bug" instead of just "bug"
- Be explicit: "fix the visual issue with the button"

### Verification fails repeatedly

- The skill will try up to 5 iterations
- Check `.opencode/ui-bug-fix/state.json` for attempt history
- Manual intervention may be needed for complex issues

### Dev server won't start

- Ensure port 9000 is available
- Check that `npm run start` works manually
- Review server logs in the output

### No files found

- The skill only works with React/Vue/Angular style SPAs
- Ensure components have descriptive names
- Check that source files are in standard locations
