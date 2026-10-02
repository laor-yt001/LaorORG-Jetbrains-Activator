#!/usr/bin/env bash
# បិទ set -u ដើម្បីកុំឱ្យទាស់ជាមួយ Variable ពេលរត់អនឡាញ

SCRIPT_PATH="https://raw.githubusercontent.com/laor-yt001/LaorORG-Jetbrains-Activator/refs/heads/main/LaorORG-JetBrainsIDEA-Activator.ps1"

if command -v pwsh >/dev/null 2>&1; then
  # ប្រើ -Command "iex (curl ...)" ជំនួសឱ្យ -File ព្រោះ pwsh លើ Linux មិនស្គាល់ URL ឡើយ
  pwsh -NoProfile -ExecutionPolicy Bypass -Command "iex (curl -sL '$SCRIPT_PATH')"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (curl -sL '$SCRIPT_PATH')"
else
  echo "PowerShell is not installed. Please install pwsh (recommended) or powershell." >&2
  exit 1
fi
