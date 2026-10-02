#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_PS1_URL="https://raw.githubusercontent.com/laor-yt001/LaorORG-Jetbrains-Activator/refs/heads/main/LaorORG-JetBrainsIDEA-Activator.ps1"
PORTABLE_DIR="${SCRIPT_DIR}/.pwsh-portable"

PS1_PATH=""
for candidate in \
  "${SCRIPT_DIR}/LaorORG-JetBrainsIDEA-Activator.ps1" \
  "${SCRIPT_DIR}/LaorORG-JetBrainsIDEA-Activator (1).ps1"; do
  if [[ -f "$candidate" ]]; then
    PS1_PATH="$candidate"
    break
  fi
done

if [[ -z "$PS1_PATH" ]]; then
  PS1_PATH="${SCRIPT_DIR}/LaorORG-JetBrainsIDEA-Activator.ps1"
  echo "Downloading upstream PowerShell script from GitHub..."
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 -o "$PS1_PATH" "$REMOTE_PS1_URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$PS1_PATH" "$REMOTE_PS1_URL"
  else
    echo "curl or wget is required to download the PowerShell script." >&2
    exit 1
  fi
fi

if [[ ! -f "$PS1_PATH" ]]; then
  echo "PowerShell script not found: $PS1_PATH" >&2
  exit 1
fi

if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$PS1_PATH" "$@"
fi

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "curl or wget is required to download a portable PowerShell runtime." >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required to extract the portable PowerShell runtime." >&2
  exit 1
fi

OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"

case "$OS_NAME" in
  Linux) OS_TAG="linux" ;;
  *)
    echo "This launcher is intended for Linux only. Detected: $OS_NAME" >&2
    exit 1
    ;;
esac

case "$ARCH_NAME" in
  x86_64|amd64) ARCH_TAG="x64" ;;
  aarch64|arm64) ARCH_TAG="arm64" ;;
  *)
    echo "Unsupported CPU architecture: $ARCH_NAME" >&2
    exit 1
    ;;
esac

PS_VERSION="${PS_VERSION:-7.5.1}"
TARBALL="powershell-${PS_VERSION}-${OS_TAG}-${ARCH_TAG}.tar.gz"
URL="https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${TARBALL}"

mkdir -p "$PORTABLE_DIR"
TARBALL_PATH="${PORTABLE_DIR}/${TARBALL}"

if [[ ! -x "${PORTABLE_DIR}/pwsh" ]]; then
  echo "Downloading portable PowerShell v${PS_VERSION}..."
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 --output "$TARBALL_PATH" "$URL"
  else
    wget -O "$TARBALL_PATH" "$URL"
  fi

  tar -xzf "$TARBALL_PATH" -C "$PORTABLE_DIR"
  chmod +x "${PORTABLE_DIR}/pwsh"
fi

exec "${PORTABLE_DIR}/pwsh" -NoProfile -ExecutionPolicy Bypass -File "$PS1_PATH" "$@"
