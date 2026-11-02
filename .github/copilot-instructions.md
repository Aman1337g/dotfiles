# Copilot instructions

See [AGENTS.md](../AGENTS.md) for full context.

Three critical rules:
1. Never re-implement detection/backup/link logic — reuse `lib/detect.sh` / `lib/backup.sh`.
2. Package lists go in `packages/<mgr>` / `packages/gui.<mgr>`, never inline arrays.
3. `setup` clones into `~/.dotfiles` if missing — CI/tests must seed that dir from the checkout, or they test `main`, not the branch.
