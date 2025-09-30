# AUTOMATIC1111 Stop Script
# Safely stops AUTOMATIC1111 and disables auto-restart

Write-Host "Stopping AUTOMATIC1111..." -ForegroundColor Yellow

# Stop Python processes
$pythonProcesses = Get-Process python -ErrorAction SilentlyContinue
if ($pythonProcesses) {
    Write-Host "Stopping Python processes..." -ForegroundColor Cyan
    $pythonProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Python processes stopped" -ForegroundColor Green
}

# Stop processes using port 7860
$portProcesses = netstat -ano | Select-String ":7860"
if ($portProcesses) {
    Write-Host "Stopping processes on port 7860..." -ForegroundColor Cyan
    $portProcesses | ForEach-Object {
        $processId = ($_.Line -split '\s+')[-1]
        if ($processId -match '^\d+$') {
            taskkill /PID $processId /F 2>$null
        }
    }
    Write-Host "Port 7860 processes stopped" -ForegroundColor Green
}

# Check auto-start task status
$task = Get-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "Checking auto-start task..." -ForegroundColor Cyan
    if ($task.State -eq "Ready") {
        Write-Host "WARNING: Auto-start task is ENABLED" -ForegroundColor Yellow
        Write-Host "AUTOMATIC1111 WILL restart on reboot!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To disable auto-start (requires Admin):" -ForegroundColor Cyan
        Write-Host "  Right-click PowerShell -> 'Run as Administrator'" -ForegroundColor White
        Write-Host "  Disable-ScheduledTask -TaskName 'AUTOMATIC1111-AutoStart'" -ForegroundColor White
    } elseif ($task.State -eq "Disabled") {
        Write-Host "Auto-start task is disabled - will NOT restart on reboot" -ForegroundColor Green
    }
}

# Verify
Start-Sleep 2
$remaining = Get-Process python -ErrorAction SilentlyContinue
$portCheck = netstat -ano | Select-String ":7860" -Quiet

if (-not $remaining -and -not $portCheck) {
    Write-Host ""
    Write-Host "AUTOMATIC1111 is stopped" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Some processes may still be running" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To restart: .\start.ps1" -ForegroundColor Cyan