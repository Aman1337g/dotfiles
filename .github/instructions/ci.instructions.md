---
applyTo: ".github/workflows/**"
---

Full rules and rationale: AGENTS.md. Scoped to this path:
- New jobs that run the full matrix should `needs: shellcheck`, so lint gates the expensive part.
- Steps default to cwd `$GITHUB_WORKSPACE` — don't assume `~/.dotfiles` without an explicit `cd` (the dry-run step does `cd` after seeding; most others don't need to).
- `permissions: contents: read` at top level is intentional and minimal — don't widen it without a stated reason.
