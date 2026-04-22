## Summary

<!-- Describe your changes in 2-3 sentences. What does this PR do and why? -->

## Linked Issue

<!-- Link to the GitHub issue or JIRA ticket this PR addresses -->
Fixes #

## Type of Change

<!-- Put an `x` in the boxes that apply -->

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Enhancement (improvement to existing functionality)
- [ ] Refactoring (code restructure, no behavior change)
- [ ] Dependency update
- [ ] Documentation
- [ ] CI/CD

## Feature Flag Impact

<!-- Does this PR add, remove, or change any feature flags? -->

- [ ] No feature flag changes
- [ ] Adds new flag: `___________`
- [ ] Modifies existing flag: `___________`

## Screenshots (UI Changes)

<!-- Include before/after screenshots for any UI changes. Delete this section if not applicable. -->

## Test Plan

<!-- How was this tested? -->

- [ ] Manual testing (describe steps below)
- [ ] Unit tests added / updated
- [ ] Cypress E2E tests added / updated (`npm run cy:open`)
- [ ] Playwright tests added / updated (`npm run pw:test`)

**Steps to test:**
1.
2.
3.

**Where to test:**

- [ ] INTEG
- [ ] SANDBOX
- [ ] PROD

## AI-Assisted?

- [ ] This PR was written or reviewed with AI assistance (Claude, Copilot, Cursor, etc.)

## Checklist

<!-- Put an `x` in all boxes that apply before requesting review -->

- [ ] Commit message follows Conventional Commits format (`feat/fix/chore/refactor/docs/test/style: description`)
- [ ] Commit is GPG-signed
- [ ] `typos` spell-check passes
- [ ] `npm run re:build` passes (no ReScript compilation errors)
- [ ] `npm run lint:hooks` passes (zero ESLint warnings)
- [ ] Jest tests pass (if applicable)
- [ ] Cypress / Playwright passes locally (if applicable)
- [ ] No `src/` changes included in documentation-only PRs
- [ ] No secrets, API keys, or credentials committed
- [ ] I reviewed submitted code
