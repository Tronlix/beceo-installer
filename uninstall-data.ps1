# BeCEO Uninstall - Data & Service Removal Script
Add-Type -AssemblyName System.Windows.Forms

# Step 1: Stop BeCEO service
Write-Host "Stopping BeCEO service..." -ForegroundColor Yellow
try { & beceo stop 2>$null } catch {}

# Step 2: Uninstall the background service
Write-Host "Removing background service..." -ForegroundColor Yellow
try { & beceo uninstall 2>$null } catch {}

# Step 3: Force remove Task Scheduler entry (cleanup in case beceo uninstall missed it)
Write-Host "Cleaning up Task Scheduler..." -ForegroundColor Yellow
$taskNames = @("OpenClaw Gateway", "BeCEO Gateway")
foreach ($task in $taskNames) {
    $exists = schtasks /Query /TN $task 2>$null
    if ($LASTEXITCODE -eq 0) {
        schtasks /Delete /F /TN $task 2>$null
        Write-Host "   Removed task: $task" -ForegroundColor Green
    }
}

# Step 4: Ask whether to remove user data
$result = [System.Windows.Forms.MessageBox]::Show(
    "Do you want to remove all BeCEO data?`n`nThis includes memory, personality, and configuration stored in:`n  %USERPROFILE%\.beceo`n  %USERPROFILE%\.openclaw`n`nClick Yes to remove everything, or No to keep your data.",
    "Uninstall BeCEO",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    $paths = @(
        (Join-Path $env:USERPROFILE ".beceo"),
        (Join-Path $env:USERPROFILE ".openclaw")
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
            Write-Host "Removed: $p" -ForegroundColor Green
        }
    }
    Write-Host "All BeCEO data removed." -ForegroundColor Green
} else {
    Write-Host "User data kept." -ForegroundColor Cyan
}
