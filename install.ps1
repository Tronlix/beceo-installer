# BeCEO Windows Installer
# Right-click -> Run with PowerShell (as Administrator)

$ErrorActionPreference = "Stop"
$NODE_VERSION = "22.14.0"
$BECEO_TGZ = "beceo-V1Beta.tgz"

function Write-Step($msg) {
    Write-Host "`n>> $msg" -ForegroundColor Cyan
}

function Write-OK($msg) {
    Write-Host "   [OK] $msg" -ForegroundColor Green
}

function Write-Fail($msg) {
    Write-Host "   [ERROR] $msg" -ForegroundColor Red
    exit 1
}

Clear-Host
Write-Host ""
Write-Host "  +==================================+" -ForegroundColor Magenta
Write-Host "  |        BeCEO Installer           |" -ForegroundColor Magenta
Write-Host "  +==================================+" -ForegroundColor Magenta
Write-Host ""

# Step 1: Check files
Write-Step "Step 1: Checking installation files"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tgzPath = Join-Path $scriptDir $BECEO_TGZ
if (-not (Test-Path $tgzPath)) {
    Write-Fail "Cannot find $BECEO_TGZ. Please make sure it is in the same folder as install.ps1"
}
Write-OK "Found $BECEO_TGZ"

# Step 2: Check Node.js
Write-Step "Step 2: Checking Node.js"
$nodeInstalled = $false
try {
    $nodeVer = node --version 2>$null
    if ($nodeVer -match "v(\d+)\.") {
        $major = [int]$Matches[1]
        if ($major -ge 22) {
            Write-OK "Node.js $nodeVer is already installed"
            $nodeInstalled = $true
        } else {
            Write-Host "   Node.js $nodeVer is too old (need v22+), will upgrade..." -ForegroundColor Yellow
        }
    }
} catch {}

if (-not $nodeInstalled) {
    Write-Host "   Downloading Node.js v${NODE_VERSION}..." -ForegroundColor Yellow
    $msiUrl = "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-x64.msi"
    $msiPath = "$env:TEMP\node-setup.msi"
    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -UseBasicParsing
        Write-Host "   Installing Node.js (please wait)..." -ForegroundColor Yellow
        Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait

        # Refresh PATH without quotes issue
        $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path = $machinePath + ';' + $userPath

        Write-OK "Node.js installed successfully"
    } catch {
        Write-Fail "Failed to download Node.js. Please install manually from https://nodejs.org"
    }
}

# Step 3: Install BeCEO
Write-Step "Step 3: Installing BeCEO"
try {
    Write-Host "   Running npm install (this may take a few minutes)..." -ForegroundColor Yellow
    & npm install -g $tgzPath
    if ($LASTEXITCODE -ne 0) { Write-Fail "npm install failed" }
    Write-OK "BeCEO installed successfully"
} catch {
    Write-Fail "Installation failed: $_"
}

# Step 4: Initial setup
Write-Step "Step 4: Initial Setup"
Write-Host ""
Write-Host "   Starting BeCEO setup wizard..." -ForegroundColor Yellow
Write-Host "   Please follow the prompts to complete your configuration." -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 2

try {
    # Launch beceo setup in a new window so this installer window can close independently
    Start-Process "cmd" -ArgumentList "/k beceo setup"
} catch {
    Write-Host "   [WARN] Setup could not run. You can run it manually later with: beceo setup" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  +==================================+" -ForegroundColor Green
Write-Host "  |   Installation Complete!         |" -ForegroundColor Green
Write-Host "  |                                  |" -ForegroundColor Green
Write-Host "  +==================================+" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
