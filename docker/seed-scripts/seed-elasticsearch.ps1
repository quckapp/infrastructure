# =============================================================================
# QuckApp Elasticsearch Seed Orchestrator (PowerShell)
# =============================================================================

$ES_URL = if ($env:ES_URL) { $env:ES_URL } else { "http://localhost:9200" }
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InitScript = Join-Path $ScriptDir "..\init-scripts\elasticsearch\01-init-indices.sh"

Write-Host "=== Elasticsearch Seed Orchestrator ===" -ForegroundColor Cyan

# Wait for ES to be healthy
Write-Host "Checking Elasticsearch at $ES_URL..."
for ($i = 1; $i -le 30; $i++) {
    try {
        $response = Invoke-RestMethod -Uri "$ES_URL/_cluster/health" -Method Get -ErrorAction Stop
        if ($response.status -eq "green" -or $response.status -eq "yellow") {
            Write-Host "Elasticsearch is ready." -ForegroundColor Green
            break
        }
    } catch {
        # ES not ready
    }
    if ($i -eq 30) {
        Write-Host "ERROR: Elasticsearch not ready after 30 attempts." -ForegroundColor Red
        exit 1
    }
    Write-Host "Waiting for Elasticsearch... ($i/30)"
    Start-Sleep -Seconds 2
}

# Check if indices exist
try {
    $null = Invoke-RestMethod -Uri "$ES_URL/messages" -Method Get -ErrorAction Stop
    Write-Host "Indices already exist. Skipping seed." -ForegroundColor Yellow
    exit 0
} catch {
    # Index doesn't exist, proceed
}

# Run init script via Git Bash or WSL
Write-Host "Running init script..."
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    & $gitBash $InitScript
} elseif (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash $InitScript
} else {
    Write-Host "ERROR: Git Bash or WSL required to run init script." -ForegroundColor Red
    exit 1
}

Write-Host "Done." -ForegroundColor Green
