#!/usr/bin/env bash
# tests/detect-fixtures.sh - Asserts detect_pkg_mgr() against fixture /etc/os-release files.
# Run directly: bash tests/detect-fixtures.sh

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/../lib/detect.sh"

# fixture:expected_pkg_mgr
CASES=(
  "debian:apt"
  "ubuntu:apt"
  "fedora:dnf"
  "void:xbps"
  "alpine:apk"
  "arch:pacman"
  "manjaro:pacman"
  "endeavouros:pacman"
  "unknown:unknown"
)

fail=0
for case_spec in "${CASES[@]}"; do
  fixture="${case_spec%%:*}"
  expected="${case_spec#*:}"
  fixture_path="$SCRIPT_DIR/fixtures/os-release.$fixture"

  if [ ! -f "$fixture_path" ]; then
    echo "✗ $fixture: missing fixture file $fixture_path"
    fail=1
    continue
  fi

  actual="$(DETECT_OS_RELEASE_FILE="$fixture_path" detect_pkg_mgr)"
  if [ "$actual" = "$expected" ]; then
    echo "✓ $fixture -> $actual"
  else
    echo "✗ $fixture: expected '$expected', got '$actual'"
    fail=1
  fi
done

exit "$fail"
