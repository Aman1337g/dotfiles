---
applyTo: "**/*.sh,setup,install_tools,link,lib/**"
---

Full rules and rationale: AGENTS.md. Scoped to this path:
- Run `bash -n <file>` immediately after editing, before saying it's done.
- A `# shellcheck disable=SCxxxx` needs a trailing reason comment (see `lib/backup.sh`).
- `packages/*` manifests are parsed with `grep -vE '^[[:space:]]*(#|$)'` — comments must start the line (leading whitespace OK), no inline trailing comments on a package line.
