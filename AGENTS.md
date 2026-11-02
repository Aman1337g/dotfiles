# AGENTS.md

## What this repo is
A Bash + GNU Stow + `mise`-first dotfiles bootstrapper. Targets Linux (apt/dnf/xbps/apk/pacman), macOS, WSL, Android (Termux), Windows Git Bash, and ephemeral containers (DevPod/Docker). Native package managers only install lifelines (git, curl, stow, build tools); `mise` provisions almost everything else via per-OS `config.toml` overlays.

## Layout map
- One Stow package per tool at repo root: `bash/ git/ nvim/ tmux/ starship/ mise/ kitty/ sway/ ...`.
- Each mirrors a `$HOME` path (e.g. `bash/.bashrc` -> `~/.bashrc`).
- **Don't** restructure these into `core/`/`os/`-style folders — it's one-stow-package-per-tool by design, not a layering scheme.
- `lib/detect.sh` — `detect_env_type()` (linux/wsl/mac/container/termux/windows) and `detect_pkg_mgr()` (apt/dnf/xbps/apk/pacman/brew/pkg/winget).
- Single source of truth; `setup` and `install_tools` both source it, neither re-detects on its own.
- `lib/backup.sh` — `CORE_LINKS`/`GUI_TARGETS` arrays + backup-before-link functions, shared by `setup`'s Stow runway-clearing and `link`'s manual fallback.
- `packages/` — declarative manifests, one package per line, `#` comments allowed.
- `packages.<mgr>` (base lifelines) and `gui.<mgr>` (desktop extras, `install_tools --gui`). `Brewfile`/`winget.json` stay in their native formats.
- `os/` — platform-exclusive assets that aren't full Stow packages (e.g. `os/wsl/sysctl.conf`).
- `tests/` — `detect-fixtures.sh` + `fixtures/os-release.*`, `local-matrix.sh`, `verify-tools.txt`.
- `.github/` — `workflows/ci.yml`, `dependabot.yml`.
- Entry points: `setup` (orchestrator: clone -> detect -> link -> install), `install_tools` (package manager + mise), `link` (manual symlink fallback, no Stow needed).

## Commands
- `bash tests/detect-fixtures.sh` — fast, no container; asserts `detect_pkg_mgr` against 9 fixture `/etc/os-release` files.
- `bash tests/local-matrix.sh` — shellcheck + fixtures + a full `setup --auto --env=container` dry-run (x2, idempotency) on debian-12/ubuntu-24.04/fedora-40/archlinux-latest, via podman or docker (auto-picked).
- `podman run --rm -v "$PWD":/mnt:ro -w /mnt docker.io/koalaman/shellcheck:stable <files>` — shellcheck without installing it locally.
- `gh pr checks <n> --watch` — watch CI on an open PR.
- `gh run view <id> --log-failed` — pull a failing job's log.

## Adding a distro / package manager
1. `lib/detect.sh`: map the OS signal (`ID`/`ID_LIKE`, or another real signal) to a new `PKG_MGR` value.
2. `packages/packages.<mgr>` + `packages/gui.<mgr>` (plain text, one package per line).
3. `install_tools`: add a `<mgr>)` case branch.
4. `tests/fixtures/os-release.<name>` + a case in `tests/detect-fixtures.sh`.
5. A matrix entry in BOTH `.github/workflows/ci.yml` and `tests/local-matrix.sh` — keep them in sync.
6. Update the README platform list.
The post-bootstrap tool-verification list lives once, in `tests/verify-tools.txt` — both CI and `local-matrix.sh` read it.

## Coding rules
- `set -euo pipefail` everywhere.
- `$USER` can be unset in containers: use `${USER:-$(id -un)}`.
- Reuse `lib/detect.sh` / `lib/backup.sh` — never re-implement detection, backup, or link logic in a script.
- Use the `_sudo` wrapper (falls back to running directly when `sudo` is absent) instead of bare `sudo`.
- Package lists go in `packages/`, never as inline bash arrays.
- Preserve the `--auto`, `--gui`, `--env=` flags and the `curl | bash` piped-execution path.
- No behavior change for a platform you can't actually test.

## Hard-won gotchas
- GitHub Actions container jobs default `run:` steps to `sh` (dash on Debian/Ubuntu).
- Dash lacks process substitution (`<(...)`) and arrays, which `mapfile`-based scripts need — pin `defaults.run.shell: bash` on any job using `container:`.
- `setup` clones upstream into `~/.dotfiles` if it's missing.
- `ensure_git` in `setup` runs before the clone and cannot use `lib/detect.sh` (not on disk yet): it probes package managers inline and keeps `</dev/null` on installers so they can't eat a piped (`curl | bash`) script.
- CI/local harnesses must seed `~/.dotfiles` from the checkout first, or they silently test remote `main` instead of the PR.
- Arch: always `pacman -Syu --needed`, never bare `-Sy` (partial upgrades are unsupported).
- `pacman`/libalpm ignores `CURL_CA_BUNDLE`/`SSL_CERT_FILE` — a corporate TLS-inspection CA has to go into the system trust store instead.
- `get.docker.com` is unsupported on Arch (pacman installs docker directly); AUR/yay is out of scope.
- starship isn't in default Debian/Fedora repos — `install_tools` falls back to the upstream installer.
- Fedora's minimal image needs an explicit `libatomic` package for node.
- mise's GitHub release fetches (e.g. neovim) hit the unauthenticated API rate limit — pass `GITHUB_TOKEN`.
- `mise install -y` returns nonzero if even one tool fails — `install_tools` catches that itself (warns, keeps going to `mise reshim`) so one transient failure doesn't strand every other tool unshimmed; don't re-wrap it in another layer of error-swallowing.
- The repo author's network does TLS inspection; `local-matrix.sh` optionally mounts a host CA bundle for that — not needed on GitHub-hosted runners.
- Never swallow a command's output with `>/dev/null 2>&1` under `set -e` if something downstream depends on its exit code.
- Never pipe into `tail`/`grep` without `pipefail` — both have silently masked real failures here before.
- `git add` re-stages a file's mode from disk. If an executable script loses its `+x` bit, `chmod` it on disk before committing and verify with `git ls-files -s`.
- Pin third-party GitHub Actions to a full commit SHA with a trailing `# vX.Y.Z` comment (Dependabot's `github-actions` ecosystem keeps them current).
- Container base images stay version-tagged; `archlinux:latest` is intentionally floating — Arch is rolling-release, there's no versioned equivalent.

## CI / test coverage — the truth
Actually tested, every push, twice each (idempotency) + GUI-manifest validation: **debian-12, ubuntu-24.04, fedora-40, archlinux-latest**.
NOT continuously tested: Void, Alpine, macOS, Windows Git Bash, Termux, WSL, the native (non-container) Docker-install code paths, the interactive menu. Don't claim coverage for these — say "untested" explicitly.

## Boundaries — never
- Never commit secrets or machine-specific identity. The work/personal git identity split is a local, git-ignored `~/.gitconfig-work` overlay (see `git/.gitconfig`'s `includeIf` blocks) — don't edit identity fields in `git/.gitconfig` / `git/.ssh/config` directly, and don't add a tracked `work/` directory.
- Don't restructure the existing Stow packages (one directory per tool) into a different layout.
- Don't add an unpinned download without a `# TODO: pin version + checksum` comment — the existing accepted-risk pipe-to-shell installs (`get.docker.com`, `mise.run`, `starship.rs/install.sh`) already carry one; match that pattern.
- Don't push to `main`, force-push, or merge — PRs only, squash-merged by a human.

## Verification protocol (definition of done)
Run what you can for real: `bash -n`, shellcheck, the fixture tests, `local-matrix.sh`. No stub/fake binaries to simulate a result. Anything you didn't actually execute is UNVERIFIED — say so, don't imply it passed. For CI-only behavior, push to a PR branch and read `gh pr checks` / `gh run view --log-failed`. When something fails, diagnose the root cause, not the symptom.

## Workflow conventions
Conventional commits (`feat:`, `fix:`, `ci:`, `test:`, `docs:`), small and scoped. PRs via `gh`, squash-merged. Commits are SSH-signed by the repo owner — if your environment can't sign, don't disable signing: hand over a copy-paste `git add ... && git commit -S -m "..."` block and wait. Use real edit/create tools for file changes — never `sed -i`, heredocs, or a `python3` one-liner to write a repo file.

## Keep this file current
Update AGENTS.md in the same PR when you change a command, the layout, or discover a new gotcha. Prune stale content rather than appending — keep this under ~140 lines.
