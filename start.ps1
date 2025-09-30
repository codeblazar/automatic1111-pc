# AUTOMATIC1111 Startup Script
# Starts the WebUI with API enabled in background

Write-Host "Starting AUTOMATIC1111..." -ForegroundColor Green

if (-not (Test-Path "webui")) {
    Write-Host "[ERROR] AUTOMATIC1111 not installed. Run setup-native.ps1 first" -ForegroundColor Red
    exit 1
}

# Re-enable auto-start task if it was disabled
try {
    $task = Get-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart" -ErrorAction SilentlyContinue
    if ($task -and $task.State -eq "Disabled") {
        Enable-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart" -ErrorAction SilentlyContinue
        Write-Host "Re-enabled auto-start task" -ForegroundColor Green
    }
} catch {
    # Ignore errors - task may not exist
}

# Check if already running
$existingProcesses = Get-Process python -ErrorAction SilentlyContinue
$portInUse = netstat -ano | Select-String ":7860" -Quiet

if ($existingProcesses -and $portInUse) {
    Write-Host ""
    Write-Host "✅ AUTOMATIC1111 is already running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "  Web UI:      http://localhost:7860" -ForegroundColor White
    Write-Host "  Swagger API: http://localhost:7860/docs" -ForegroundColor White
    Write-Host ""
    Write-Host "Management:" -ForegroundColor Yellow
    Write-Host "  Stop:        .\stop.ps1" -ForegroundColor White
    Write-Host "  Restart:     .\stop.ps1; .\start.ps1" -ForegroundColor White
    Write-Host "  Check status: Get-Process python" -ForegroundColor White
    exit 0
}

# Start AUTOMATIC1111 in background
Write-Host "Launching AUTOMATIC1111 in background..." -ForegroundColor Yellow
try {
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "cd /d `"$PWD\webui`" && webui-user.bat" -WindowStyle Hidden -PassThru
    Write-Host "Process started with ID: $($process.Id)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to start AUTOMATIC1111: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Wait a moment for startup
Write-Host "Waiting for startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check if it started successfully
$attempts = 0
$maxAttempts = 90  # 3 minutes total (90 * 2 seconds)
$started = $false

Write-Host "Note: AUTOMATIC1111 startup typically takes 1-3 minutes" -ForegroundColor Cyan

while ($attempts -lt $maxAttempts -and -not $started) {
    $attempts++
    
    # Check if process is still running
    if (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] AUTOMATIC1111 process terminated unexpectedly" -ForegroundColor Red
        Write-Host "Check logs in webui directory for details" -ForegroundColor Yellow
        exit 1
    }
    
    # Check if web server is responding
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:7860" -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $started = $true
            break
        }
    } catch {
        # Still starting up
    }
    
    if ($attempts % 10 -eq 0) {
        $minutes = [math]::Round($attempts * 2 / 60, 1)
        Write-Host "  Still loading... ($minutes minutes elapsed)" -ForegroundColor White
    }
    
    Start-Sleep -Seconds 2
}

if ($started) {
    Write-Host ""
    Write-Host "[SUCCESS] AUTOMATIC1111 started successfully! 🎉" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "  Web UI:     http://localhost:7860" -ForegroundColor White
    Write-Host "  Swagger API: http://localhost:7860/docs" -ForegroundColor White
    Write-Host ""
    Write-Host "Management:" -ForegroundColor Yellow
    Write-Host "  Stop:       .\stop.ps1" -ForegroundColor White
    Write-Host "  Restart:    .\stop.ps1; .\start.ps1" -ForegroundColor White
    Write-Host "  Processes:  Get-Process python" -ForegroundColor White
    Write-Host ""
    Write-Host "Running in background (Process ID: $($process.Id))" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[INFO] AUTOMATIC1111 is still starting up (this is normal)" -ForegroundColor Yellow
    Write-Host "Startup typically takes 1-3 minutes, first time can take 5-15 minutes" -ForegroundColor White
    Write-Host ""
    Write-Host "Try accessing in a few minutes:" -ForegroundColor Cyan
    Write-Host "  Web UI: http://localhost:7860" -ForegroundColor White
    Write-Host "  Process ID: $($process.Id)" -ForegroundColor White
    Write-Host ""
    Write-Host "To check status: Get-Process python" -ForegroundColor Cyan
    Write-Host "To monitor: Get-Content webui\\*.log -Wait" -ForegroundColor Cyan
}