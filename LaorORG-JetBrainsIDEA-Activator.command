#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/LaorORG-JetBrainsIDEA-Activator.ps1"

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_PATH" -Offline "$@"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_PATH" -Offline "$@"
else
  echo "PowerShell is not installed. Please install pwsh (recommended) or powershell." >&2
  read -p "Press Enter to exit..." 
  exit 1
fi
