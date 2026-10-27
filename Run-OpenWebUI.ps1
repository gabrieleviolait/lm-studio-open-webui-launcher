# Script di avvio nativo di Open WebUI, creato da https://www.gabrieleviola.it/
# Licenza MIT per questo script; Open WebUI ha licenza upstream separata.
param([Parameter(Mandatory=$true)][string]$Uvx)
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:LOCALAPPDATA 'LMStudio-OpenWebUI-ChatLAN'
New-Item -ItemType Directory -Path $root -Force | Out-Null
$env:DATA_DIR = Join-Path $root 'data'
New-Item -ItemType Directory -Path $env:DATA_DIR -Force | Out-Null
$secretPath = Join-Path $root 'secret.txt'
if (-not (Test-Path -LiteralPath $secretPath)) {
    $buffer = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($buffer) } finally { $rng.Dispose() }
    $secret = ([System.BitConverter]::ToString($buffer)).Replace('-', '').ToLowerInvariant()
    [System.IO.File]::WriteAllText($secretPath, $secret)
}
$env:WEBUI_SECRET_KEY = [System.IO.File]::ReadAllText($secretPath).Trim()
# Pensato per una LAN domestica fidata: accesso senza login, solo per nuove installazioni.
$env:WEBUI_AUTH = 'False'
$env:OPENAI_API_BASE_URL = 'http://127.0.0.1:1234/v1'
$env:OPENAI_API_KEY = 'none'
$env:ENABLE_OLLAMA_API = 'False'
$env:FORWARDED_ALLOW_IPS = '127.0.0.1'
Write-Host 'Open WebUI nativo: primo avvio potrebbe scaricare molte dipendenze.' -ForegroundColor Cyan
Write-Host 'Il modello continua a girare in LM Studio sul PC Windows.'
Write-Host 'Per arrestare il server premi Ctrl+C in questa finestra.'
& $Uvx --python 3.12 open-webui@latest serve --host 0.0.0.0 --port 3000
if ($LASTEXITCODE -ne 0) { Write-Host ('Open WebUI terminato con errore: ' + $LASTEXITCODE) -ForegroundColor Red }
