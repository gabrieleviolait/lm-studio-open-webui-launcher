@echo off
chcp 65001 >nul
title Open WebUI Launcher for LM Studio
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-OpenWebUI.ps1"
if errorlevel 1 (
  echo.
  echo Procedura non completata: leggi il messaggio di errore sopra.
  pause
)
