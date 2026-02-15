# =============================================================================
# QuckApp - Elasticsearch Seed Script (PowerShell)
# =============================================================================
# Seeds Elasticsearch with index templates and sample data.
# Called by the bootstrap script after Elasticsearch is healthy.
# =============================================================================

$ErrorActionPreference = "Stop"

$ES_HOST = if ($env:ES_HOST) { $env:ES_HOST } else { "localhost" }
$ES_PORT = if ($env:ES_PORT) { $env:ES_PORT } else { "9200" }
$ES_URL = "http://${ES_HOST}:${ES_PORT}"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InitScript = Join-Path $ScriptDir "..\init-scripts\elasticsearch\01-init-indices.sh"

Write-Host "=== Elasticsearch Seed Script ===" -ForegroundColor Cyan

# Check if Elasticsearch is reachable
try {
    $null = Invoke-RestMethod -Uri "$ES_URL/_cluster/health" -Method Get -TimeoutSec 5
} catch {
    Write-Host "ERROR: Elasticsearch is not reachable at $ES_URL" -ForegroundColor Red
    exit 1
}

# Check if indices already exist
try {
    $null = Invoke-RestMethod -Uri "$ES_URL/messages" -Method Get -TimeoutSec 5
    Write-Host "Elasticsearch indices already exist. Skipping seed." -ForegroundColor Yellow
    Write-Host "To re-seed, delete indices first:" -ForegroundColor Yellow
    Write-Host "  Invoke-RestMethod -Uri '$ES_URL/messages,channels,files,users' -Method Delete" -ForegroundColor Gray
    exit 0
} catch {
    # Index doesn't exist, proceed with seeding
}

# Run the init script via bash (Git Bash or WSL)
if (Test-Path $InitScript) {
    Write-Host "Running Elasticsearch init script..."
    $env:ES_HOST = $ES_HOST
    $env:ES_PORT = $ES_PORT

    # Try Git Bash first, then WSL
    $bashPath = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path $bashPath) {
        & $bashPath $InitScript
    } elseif (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash $InitScript
    } else {
        Write-Host "WARNING: No bash available. Running with PowerShell curl fallback..." -ForegroundColor Yellow
        # Fallback: use Invoke-RestMethod for each operation
        # This is a simplified version - the full bash script is preferred
        Write-Host "Please install Git Bash or WSL to run the full init script." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Elasticsearch seeding complete!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Init script not found at $InitScript" -ForegroundColor Red
    exit 1
}
