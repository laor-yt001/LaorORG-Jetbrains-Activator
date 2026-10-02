#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/LaorORG-JetBrainsIDEA-Activator.ps1"

if command -v pwsh >/dev/null 2>&1; then
  if [ "$(id -u 2>/dev/null || echo 0)" = "0" ] || [ -n "${SUDO_USER:-}" ]; then
    pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_PATH" -Offline "$@"
  else
    pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_PATH" -Offline "$@"
  fi
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_PATH" -Offline "$@"
else
  echo "PowerShell is not installed. Please install pwsh (recommended) or powershell." >&2
  exit 1
fi
