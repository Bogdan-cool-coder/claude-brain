# Vault Entry Templates (v3.0 — 6-folder structure)

## 3. Журнал/ — Change Log Entry

File: `3. Журнал/YYYY-MM/YYYY-MM-DD — description.md`

```markdown
---
title: [Task name]
type: changelog
status: done
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  - "[[Module1]]"
  - "[[Module2]]"
owner: Author
---
# [Task name]

**Task ID:** short-id-001
**Type:** feature | bugfix | refactor | hotfix | chore

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

## 5. Планы/ — Bug / Tech Debt Entry

File: `5. Планы/[topic].md` (append or separate file)

```markdown
---
title: Bug - [Title]
type: bugfix
status: open
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  - "[[Module]]"
owner: Author
---
# Bug: [Title]

**Discovered:** YYYY-MM-DD | **Fixed:** YYYY-MM-DD
**Severity:** Critical / High / Medium / Low
**Module:** [path]

## Symptoms -> Root Cause -> Fix
[What user saw] -> [Why] -> [What changed]

## Prevention
[Rule or pattern to prevent recurrence]
```

## 5. Планы/ — Idea / Feature Request

File: `5. Планы/[topic].md`

```markdown
---
title: [Idea]
type: idea
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  - "[[Module]]"
owner: Author
---
# [Idea]

**Category:** performance | ux | architecture | security | dx
**Complexity:** small | medium | large
**Summary:** [what's proposed]
**Benefit:** [why]
**Implementation:** [how]
```

## 2. Модули/ — Module Documentation

File: `2. Модули/[Module Name].md`

```markdown
---
title: [Module Name]
type: module
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  - "[[Related Module 1]]"
  - "[[Related Module 2]]"
owner: Author
---
# [Module Name]

## Overview
[What this module does]

## Key Components
[Files, hooks, services]

## API Endpoints
[Table of endpoints]

## Business Rules
[Non-trivial logic]
```
