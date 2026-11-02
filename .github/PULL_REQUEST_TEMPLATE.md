## What changed and why

## Verification
- [ ] `bash -n` on every touched script
- [ ] `shellcheck` (via `docker.io/koalaman/shellcheck:stable` or `bash tests/local-matrix.sh`)
- [ ] `bash tests/detect-fixtures.sh` (if `lib/detect.sh` changed)
- [ ] `bash tests/local-matrix.sh`, or `gh pr checks <n> --watch` is green
- [ ] Anything not actually executed is listed below as UNVERIFIED

## UNVERIFIED (if any)

## Out of scope / follow-up (if any)
