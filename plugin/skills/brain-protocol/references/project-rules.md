# Project-Specific Rules Template

When setting up brain for a new project, create a section in the project's CLAUDE.md with rules specific to that codebase. Example from FinFamily:

## Critical Code Rules

| # | Rule | Consequence of violation |
|---|------|------------------------|
| 1 | `Number()` around every `Decimal` from Prisma | string concat, `[object Object]` |
| 2 | `isDeleted: false` in EVERY transaction query | showing deleted data |
| 3 | `householdId` in EVERY DB query | data leak between households |
| 4 | Multi-writes via `$transaction(async (tx) => ...)` | partial writes |
| 5 | After credit account balance → `recalcCreditBalance()` | broken dashboard |
| 6 | Balance changes → `changeLog` in same transaction | lost audit trail |
| 7 | Prisma v6: `$extends()`, `Prisma.JsonNull` | TS errors |
| 8 | `createdBy`=userId(JWT), `memberId`=UserProfile.id | wrong profile |
| 9 | Changing from transfer → null `transferToAccountId/Amount` | dangling refs |
| 10 | `Date` → `.toISOString()` before JSON | invalid dates |

## Pre-Commit Check

```bash
cd packages/backend && npx tsc --noEmit && cd ../.. && pnpm test && pnpm format:check
```

## How to use

These rules stay in the PROJECT's CLAUDE.md, not in the plugin. The plugin provides the methodology; the project provides the specifics.
