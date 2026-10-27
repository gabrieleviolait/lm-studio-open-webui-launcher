# Installazione e avvio di Open WebUI tramite uv su Windows, senza Docker.
# Non modifica le installazioni Docker Desktop / WSL.
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Open WebUI Launcher for LM Studio'

function Message([string]$text, [string]$title='Open WebUI Launcher') {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show($text, $title, 'OK', 'Information') | Out-Null
    } catch { Write-Host $text }
}
function Status([string]$text) { Write-Host ('[INFO] ' + $text) -ForegroundColor Cyan }
function Fail([string]$text) { Write-Host ('[ERRORE] ' + $text) -ForegroundColor Red; Message $text 'Open WebUI Launcher - Errore'; exit 1 }
function Find-Uvx {
    $cmd = Get-Command uvx.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        "$env:USERPROFILE\.local\bin\uvx.exe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\uvx.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

Write-Host '===================================================' -ForegroundColor Cyan
Write-Host ' Open WebUI Launcher for LM Studio' -ForegroundColor Cyan
Write-Host '===================================================' -ForegroundColor Cyan
Write-Host ''

# API compatibile OpenAI di LM Studio: non richiede la LAN attiva, perche WebUI e sullo stesso PC.
Status 'Verifico LM Studio su http://127.0.0.1:1234/v1/models ...'
try {
    $models = Invoke-RestMethod -Uri 'http://127.0.0.1:1234/v1/models' -TimeoutSec 8
    if (-not $models.data) { Fail 'LM Studio risponde, ma non espone modelli. Carica un modello e avvia il server.' }
    Write-Host ('[OK]   LM Studio accessibile. Modelli API: ' + @($models.data).Count) -ForegroundColor Green
} catch {
    Fail 'LM Studio non risponde senza token. Controlla Server Running, modello Ready e Require Authentication OFF.'
}

# Avvio idempotente: se Open WebUI risponde gia, non avviarne una seconda istanza.
$existing = $false
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3000/' -UseBasicParsing -TimeoutSec 2
    if ($r.StatusCode -eq 200 -and $r.Content -match 'Open WebUI') { $existing = $true }
} catch {}
if (-not $existing) {
    $occupied = $false
    try { $occupied = (Test-NetConnection 127.0.0.1 -Port 3000 -InformationLevel Quiet -WarningAction SilentlyContinue) } catch {}
    if ($occupied) { Fail 'La porta 3000 e occupata da un altro servizio. Liberala prima di avviare Open WebUI.' }

    $uvx = Find-Uvx
    if (-not $uvx) {
        Status 'uv non presente. Installo uv tramite WinGet (strumento ufficiale Astral).'
        $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
        if (-not $winget) { Fail 'WinGet non disponibile. Installa uv da https://docs.astral.sh/uv/getting-started/installation/ e riesegui il kit.' }
        & winget.exe install --id astral-sh.uv -e --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) { Fail 'Installazione di uv non riuscita. Controlla il messaggio di WinGet.' }
        $env:Path += ";$env:USERPROFILE\.local\bin;$env:LOCALAPPDATA\Microsoft\WinGet\Links"
        $uvx = Find-Uvx
        if (-not $uvx) { Fail 'uv installato ma non ancora visibile. Chiudi la finestra e avvia nuovamente il kit.' }
    }
    Status "uv pronto: $uvx"

    $root = Join-Path $env:LOCALAPPDATA 'LMStudio-OpenWebUI-ChatLAN'
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $runner = Join-Path $PSScriptRoot 'Run-OpenWebUI.ps1'
    Status 'Avvio Open WebUI in una finestra separata. Al primo avvio scarica Python e i pacchetti necessari.'
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File',('"' + $runner + '"'),'-Uvx',('"' + $uvx + '"')) -WorkingDirectory $PSScriptRoot | Out-Null
    Write-Host 'Controllo l avvio. Nella nuova finestra puoi vedere il progresso del download.'
    $ready = $false
    for ($i=0; $i -lt 150; $i++) {
        Start-Sleep -Seconds 2
        try {
            $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3000/' -UseBasicParsing -TimeoutSec 2
            if ($r.StatusCode -eq 200) { $ready = $true; break }
        } catch {}
        if (($i + 1) % 15 -eq 0) { Write-Host ('[INFO] Installazione/avvio in corso; controlla la finestra del server...') }
    }
    if (-not $ready) { Fail 'Open WebUI non ha risposto sulla porta 3000. Controlla gli errori nella seconda finestra. Non cancellare le cartelle dati.' }
}

$ips = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {
    $_.IPAddress -match '^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.' -and $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback|Docker'
} | Select-Object -ExpandProperty IPAddress -Unique)
$lanUrl = if ($ips.Count -gt 0) { 'http://' + $ips[0] + ':3000' } else { '(individua IP con ipconfig):3000' }
Write-Host ('[OK] Open WebUI avviato: http://localhost:3000') -ForegroundColor Green
Write-Host ('[LAN] ' + $lanUrl) -ForegroundColor Green
Start-Process 'http://localhost:3000'
Message ("Open WebUI funziona!`n`nDa questo PC: http://localhost:3000`nDal telefono (stessa LAN): $lanUrl`n`nPer accedere da altri dispositivi potrebbe essere necessaria una regola firewall sulla porta TCP 3000 (solo rete privata / sottorete locale).`n`nLa finestra del server deve restare aperta.") 'Open WebUI pronto'
