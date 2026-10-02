@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = '%~dp0LaorORG-JetBrainsIDEA-Activator.ps1'; if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$p,'-Offline'); exit 0 }; & $p -Offline"
exit /b %ERRORLEVEL%
