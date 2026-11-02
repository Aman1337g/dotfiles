#!/usr/bin/env bash
# tests/local-matrix.sh - One-command local verification: shellcheck + detect fixtures +
# a full bootstrap dry-run (twice, for idempotency) across debian/ubuntu/fedora/archlinux
# containers, via whichever of podman/docker is installed. Mirrors .github/workflows/ci.yml.
#
# Usage: bash tests/local-matrix.sh
# Optional env: GITHUB_TOKEN (else tries `gh auth token`) to avoid GitHub API rate limits.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
LOG_DIR="/tmp/dotfiles-matrix"
mkdir -p "$LOG_DIR"

# --- Pick a container runtime ---
RUNTIME=""
MOUNT_SUFFIX=""
if command -v podman >/dev/null 2>&1; then
  RUNTIME="podman"
  MOUNT_SUFFIX=",Z" # SELinux relabel; harmless no-op on non-SELinux hosts.
elif command -v docker >/dev/null 2>&1; then
  RUNTIME="docker"
fi

if [ -z "$RUNTIME" ]; then
  echo "::error:: neither podman nor docker found on PATH" >&2
  exit 1
fi
echo "Using container runtime: $RUNTIME"

# --- GitHub token, to avoid rate-limiting mise's GitHub release fetches (e.g. neovim) ---
GH_TOKEN="${GITHUB_TOKEN:-}"
if [ -z "$GH_TOKEN" ] && command -v gh >/dev/null 2>&1; then
  GH_TOKEN="$(gh auth token 2>/dev/null || true)"
fi

# --- Corporate TLS inspection CA bundle (optional) ---
CA_ARGS=()
CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
if [ -f "$CA_BUNDLE" ]; then
  CA_ARGS=(-v "${CA_BUNDLE}:/host-ca.crt:ro${MOUNT_SUFFIX}" -e CURL_CA_BUNDLE=/host-ca.crt -e SSL_CERT_FILE=/host-ca.crt)
  echo "Mounting host CA bundle: $CA_BUNDLE"
else
  echo "No host CA bundle found at $CA_BUNDLE — skipping (fine on networks without TLS inspection)."
fi

declare -A RESULTS

run_step() {
  local label="$1" log="$2"
  shift 2
  echo "== $label =="
  if "$@" >"$log" 2>&1; then
    RESULTS["$label"]="PASS"
  else
    RESULTS["$label"]="FAIL"
  fi
}

# --- shellcheck (via the official image, so no local install needed) ---
SHELLCHECK_TARGETS=(setup install_tools link lib/detect.sh lib/backup.sh tests/detect-fixtures.sh tests/local-matrix.sh)
run_step "shellcheck" "$LOG_DIR/shellcheck.log" \
  "$RUNTIME" run --rm -v "${REPO_ROOT}:/mnt:ro${MOUNT_SUFFIX}" -w /mnt \
  docker.io/koalaman/shellcheck:stable "${SHELLCHECK_TARGETS[@]}"

# --- detect_pkg_mgr fixture tests (native, no container needed) ---
run_step "detect-fixtures" "$LOG_DIR/detect-fixtures.log" bash "$SCRIPT_DIR/detect-fixtures.sh"

# --- Per-distro bootstrap dry-run, twice (idempotency), then verify tools resolved ---
# Each image's default shell may be sh/dash (lacks process substitution, arrays, etc.), so
# every per-distro run below explicitly invokes bash via `bash -c` — mirrors ci.yml's
# `defaults: run: shell: bash` pin on the bootstrap-dry-run job.
# shellcheck disable=SC2016  # INNER_SCRIPT is single-quoted on purpose; it expands inside the container
INNER_SCRIPT='
set -eo pipefail
# pacman (libalpm) ignores CURL_CA_BUNDLE/SSL_CERT_FILE, so install the host bundle into the system trust store.
if [ -f /host-ca.crt ] && [ -d /etc/ca-certificates/trust-source/anchors ]; then
  cp /host-ca.crt /etc/ca-certificates/trust-source/anchors/host-ca.crt
  update-ca-trust
fi
echo "--- prerequisites ---"
eval "$LOCAL_MATRIX_PREREQS" 2>&1 | tail -n 15

echo "--- validate GUI manifest package names (no install) ---"
case "$LOCAL_MATRIX_PKG_MGR" in
apt)
  mapfile -t pkgs < <(grep -vE "^[[:space:]]*(#|$)" "/src/packages/gui.$LOCAL_MATRIX_PKG_MGR")
  apt-get install --simulate -y "${pkgs[@]}" >/dev/null
  ;;
dnf)
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    dnf repoquery --qf "%{name}" "$pkg" >/dev/null
  done < <(grep -vE "^[[:space:]]*(#|$)" "/src/packages/gui.$LOCAL_MATRIX_PKG_MGR")
  ;;
pacman)
  mapfile -t pkgs < <(grep -vE "^[[:space:]]*(#|$)" "/src/packages/gui.$LOCAL_MATRIX_PKG_MGR")
  pacman -Sp "${pkgs[@]}" >/dev/null
  ;;
esac

rm -rf /root/.dotfiles
cp -a /src /root/.dotfiles
cd /root/.dotfiles
chmod +x setup install_tools link
echo "--- first run ---"
./setup --auto --env=container
echo "--- second run (idempotency) ---"
./setup --auto --env=container
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/bin:$HOME/.local/share/mise/shims:$PATH"
fail=0
while IFS= read -r t; do
  [ -z "$t" ] && continue
  case "$t" in "#"*) continue ;; esac
  command -v "$t" >/dev/null 2>&1 || { echo "MISSING TOOL: $t"; fail=1; }
done < /src/tests/verify-tools.txt
exit "$fail"
'

# name|image|pkg_mgr|prereqs — pkg_mgr matches CI's matrix.pkg_mgr and the packages/gui.<pkg_mgr> filename.
DISTROS=(
  "debian-12|debian:12|apt|apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl ca-certificates"
  "ubuntu-24.04|ubuntu:24.04|apt|apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl ca-certificates"
  "fedora-40|fedora:40|dnf|dnf install -y git curl"
  "archlinux-latest|archlinux:latest|pacman|pacman -Syu --noconfirm git curl"
)

for spec in "${DISTROS[@]}"; do
  name="${spec%%|*}"
  rest="${spec#*|}"
  image="${rest%%|*}"
  rest="${rest#*|}"
  pkg_mgr="${rest%%|*}"
  prereqs="${rest#*|}"

  run_step "$name" "$LOG_DIR/$name.log" \
    "$RUNTIME" run --rm \
    -e HOME=/root \
    -e GITHUB_TOKEN="$GH_TOKEN" \
    -e LOCAL_MATRIX_PREREQS="$prereqs" \
    -e LOCAL_MATRIX_PKG_MGR="$pkg_mgr" \
    "${CA_ARGS[@]}" \
    -v "${REPO_ROOT}:/src:ro${MOUNT_SUFFIX}" \
    "$image" bash -c "$INNER_SCRIPT"
done

# --- Summary table ---
echo ""
echo "===================================="
echo " RESULTS"
echo "===================================="
overall=0
for label in shellcheck detect-fixtures debian-12 ubuntu-24.04 fedora-40 archlinux-latest; do
  status="${RESULTS[$label]:-FAIL}"
  printf '%-20s %s\n' "$label" "$status"
  [ "$status" = "PASS" ] || overall=1
done
echo "===================================="

for label in "${!RESULTS[@]}"; do
  if [ "${RESULTS[$label]}" = "FAIL" ]; then
    echo ""
    echo "---- last 40 lines of $LOG_DIR/$label.log ----"
    tail -n 40 "$LOG_DIR/$label.log" 2>/dev/null || echo "(no log found)"
  fi
done

exit "$overall"
