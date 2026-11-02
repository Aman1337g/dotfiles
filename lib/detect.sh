# shellcheck shell=bash
# lib/detect.sh - Single source of truth for environment + package-manager detection.
# Sourced by `install_tools` (always) and by `setup` once the repo is cloned locally.
#
# NOTE: setup's PRE-clone phase (before the repo exists on disk, e.g. curl | bash)
# cannot source this file yet, so setup clones the repo before calling detect_env_type.
# See the "CLONE DOTFILES" step in `setup` for why that ordering matters.

# Prints: linux | wsl | mac | container | termux | windows
detect_env_type() {
  if [ -n "${TERMUX_VERSION:-}" ]; then
    echo "termux"
  elif [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    echo "container"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
  else
    echo "linux"
  fi
}

# Prints: apt | dnf | xbps | apk | pacman | brew | pkg | winget | unknown
# Linux distro family is read from /etc/os-release (ID + ID_LIKE) rather than
# probing for binaries, so a minimal container with no tools yet still resolves.
# The os-release path can be overridden via DETECT_OS_RELEASE_FILE for testing
# (see tests/detect-fixtures.sh) — when overridden, the live-binary fallback below
# is skipped so test results don't depend on what the test host happens to have installed.
detect_pkg_mgr() {
  if [ -n "${TERMUX_VERSION:-}" ]; then
    echo "pkg"
    return
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "brew"
    return
  fi

  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "winget"
    return
  fi

  local os_release_file="${DETECT_OS_RELEASE_FILE:-/etc/os-release}"
  if [ -r "$os_release_file" ]; then
    local ID="" ID_LIKE=""
    # shellcheck disable=SC1090,SC1091
    . "$os_release_file"
    case " ${ID} ${ID_LIKE} " in
    *" debian "* | *" ubuntu "*)
      echo "apt"
      return
      ;;
    *" fedora "* | *" rhel "*)
      echo "dnf"
      return
      ;;
    *" void "*)
      echo "xbps"
      return
      ;;
    *" alpine "*)
      echo "apk"
      return
      ;;
    *" arch "*)
      # Covers Arch itself (ID=arch) and derivatives via ID_LIKE=arch
      # (manjaro, endeavouros, cachyos, garuda, arcolinux, ...).
      echo "pacman"
      return
      ;;
    esac
  fi

  if [ -n "${DETECT_OS_RELEASE_FILE:-}" ]; then
    echo "unknown"
    return
  fi

  # Last-resort fallback for distros without /etc/os-release matches above.
  local mgr_probe
  for mgr_probe in apt dnf xbps-install apk pacman brew; do
    if command -v "$mgr_probe" >/dev/null 2>&1; then
      [ "$mgr_probe" = "xbps-install" ] && mgr_probe="xbps"
      echo "$mgr_probe"
      return
    fi
  done

  echo "unknown"
}
