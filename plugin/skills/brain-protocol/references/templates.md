# Vault Entry Templates

## 02/ — Change Log Entry

File: `02/YYYY-MM/YYYY-MM-DD-module-name.md`

```markdown
# [Module] — [Brief description]

**Date:** YYYY-MM-DD
**Task ID:** short-id-001
**Author:** [name]

## What changed
- [File]: [description of change]

## Why
[Reasoning, link to task/issue]

## Impact
- [Affected modules/features]

## Testing
- [ ] Unit tests pass
- [ ] Manual test: [specific scenario]
```

## 04/ — Bug Analysis Entry

File: `04/YYYY-MM-DD-bug-description.md`

```markdown
# Bug: [Title]

**Date:** YYYY-MM-DD
**Module:** [name]
**Severity:** Critical / High / Medium / Low

## Symptoms
[What user saw]

## Root Cause
[Technical explanation]

## Fix
[What was changed and why]

## Prevention
[Rule or pattern to prevent recurrence]
```

## 05/ — Tech Debt Entry

File: `05/YYYY-MM-DD-debt-description.md`

```markdown
# Tech Debt: [Title]

**Date:** YYYY-MM-DD
**Module:** [name]
**Priority:** High / Medium / Low
**Effort:** S / M / L / XL

## Current State
[What's wrong]

## Desired State
[What it should be]

## Risks of Inaction
[What happens if we don't fix this]

## Proposed Approach
[How to fix]
```

## 07/ — Module Documentation

File: `07/module-name.md`

```markdown
# Module: [Name]

## Purpose
[What this module does]

## Key Files
| File | Role |
|------|------|
| `path/to/file.ts` | [description] |

## Dependencies
- [Other modules this depends on]

## API Surface
[Main exports, endpoints, etc.]

## Known Issues
- [Link to 04/ or 05/ entries]

## Last Updated
YYYY-MM-DD
```
