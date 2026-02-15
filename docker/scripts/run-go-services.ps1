# =============================================================================
# QUCKAPP - GO SERVICES RUNNER (PowerShell)
# =============================================================================
# Run Go services for different environments
# Usage: .\run-go-services.ps1 [environment] [action]
# Examples:
#   .\run-go-services.ps1 local up
#   .\run-go-services.ps1 dev build
#   .\run-go-services.ps1 production down
# =============================================================================

param(
    [string]$Environment = "local",
    [string]$Action = "up"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DockerDir = Split-Path -Parent $ScriptDir

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "QUCKAPP - GO SERVICES" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host ""

# Determine compose files based on environment
$BaseCompose = Join-Path $DockerDir "docker-compose.go-services.yml"

switch ($Environment) {
    "local" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.local.yml"
        $EnvFile = Join-Path $DockerDir ".env.local"
    }
    { $_ -in "dev", "development" } {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.dev.yml"
        $EnvFile = Join-Path $DockerDir ".env.dev"
    }
    "qa" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.qa.yml"
        $EnvFile = Join-Path $DockerDir ".env.qa"
    }
    "uat1" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.uat.yml"
        $EnvFile = Join-Path $DockerDir ".env.uat1"
    }
    "uat2" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.uat.yml"
        $EnvFile = Join-Path $DockerDir ".env.uat2"
    }
    "uat3" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.uat.yml"
        $EnvFile = Join-Path $DockerDir ".env.uat3"
    }
    "staging" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.staging.yml"
        $EnvFile = Join-Path $DockerDir ".env.staging"
    }
    { $_ -in "production", "prod" } {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.production.yml"
        $EnvFile = Join-Path $DockerDir ".env.production"
    }
    "live" {
        $OverrideCompose = Join-Path $DockerDir "docker-compose.go-services.live.yml"
        $EnvFile = Join-Path $DockerDir ".env.live"
    }
    default {
        Write-Host "Unknown environment: $Environment" -ForegroundColor Red
        Write-Host "Available environments: local, dev, qa, uat1, uat2, uat3, staging, production, live"
        exit 1
    }
}

# Check if files exist
if (-not (Test-Path $BaseCompose)) {
    Write-Host "Base compose file not found: $BaseCompose" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $EnvFile)) {
    Write-Host "Warning: Environment file not found: $EnvFile" -ForegroundColor Yellow
    $ExampleFile = Join-Path $DockerDir ".env.example"
    if (Test-Path $ExampleFile) {
        Write-Host "Creating from example..."
        Copy-Item $ExampleFile $EnvFile
    }
}

# Build compose command arguments
$ComposeArgs = @("-f", $BaseCompose)
if (Test-Path $OverrideCompose) {
    $ComposeArgs += @("-f", $OverrideCompose)
}
$ComposeArgs += @("--env-file", $EnvFile)

# Execute action
switch ($Action) {
    "up" {
        Write-Host "Starting Go services..." -ForegroundColor Green
        docker-compose @ComposeArgs up -d
        Write-Host "Services started successfully!" -ForegroundColor Green
        docker-compose @ComposeArgs ps
    }
    "up-build" {
        Write-Host "Building and starting Go services..." -ForegroundColor Green
        docker-compose @ComposeArgs up -d --build
        Write-Host "Services started successfully!" -ForegroundColor Green
        docker-compose @ComposeArgs ps
    }
    "down" {
        Write-Host "Stopping Go services..." -ForegroundColor Yellow
        docker-compose @ComposeArgs down
        Write-Host "Services stopped." -ForegroundColor Green
    }
    "restart" {
        Write-Host "Restarting Go services..." -ForegroundColor Yellow
        docker-compose @ComposeArgs restart
        Write-Host "Services restarted." -ForegroundColor Green
    }
    "build" {
        Write-Host "Building Go services..." -ForegroundColor Green
        docker-compose @ComposeArgs build
        Write-Host "Build complete." -ForegroundColor Green
    }
    "logs" {
        docker-compose @ComposeArgs logs -f
    }
    { $_ -in "ps", "status" } {
        docker-compose @ComposeArgs ps
    }
    "pull" {
        Write-Host "Pulling latest images..." -ForegroundColor Green
        docker-compose @ComposeArgs pull
    }
    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: up, up-build, down, restart, build, logs, ps, status, pull"
        exit 1
    }
}
