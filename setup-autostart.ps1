# AUTOMATIC1111 Auto-Start Setup
# Creates a Windows Task Scheduler task to start AUTOMATIC1111 on PC startup

Write-Host "Setting up AUTOMATIC1111 Auto-Start" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Get current directory
$currentDir = Get-Location
$startScript = Join-Path $currentDir "start.ps1"
$logPath = Join-Path $currentDir "logs"

# Create logs directory
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    Write-Host "[OK] Created logs directory: $logPath" -ForegroundColor Green
}

# Create the scheduled task
Write-Host "`nCreating Windows Task Scheduler entry..." -ForegroundColor Yellow

$taskName = "AUTOMATIC1111-AutoStart"
$taskDescription = "Auto-start AUTOMATIC1111 Stable Diffusion WebUI on system startup"

# Delete existing task if it exists
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "[OK] Removed existing task" -ForegroundColor Yellow
} catch { }

# Create new task action
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$startScript`"" -WorkingDirectory $currentDir

# Create trigger for startup (with delay to allow system to fully boot)
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = "PT2M"  # 2-minute delay after startup

# Create task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

# Create principal (run as current user)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $taskDescription | Out-Null

Write-Host "[OK] Task '$taskName' created successfully" -ForegroundColor Green

# Create startup monitoring script
$monitorScript = @"
# AUTOMATIC1111 Startup Monitor
# This script runs at startup and launches AUTOMATIC1111

`$logFile = "$logPath\startup-$(Get-Date -Format 'yyyy-MM-dd').log"

function Write-Log {
    param([string]`$message)
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "`$timestamp - `$message" | Out-File -FilePath `$logFile -Append
}

Write-Log "AUTOMATIC1111 auto-start initiated"

try {
    # Wait for system to stabilize
    Start-Sleep -Seconds 30
    Write-Log "System stabilization wait completed"
    
    # Change to AUTOMATIC1111 directory
    Set-Location "$currentDir"
    Write-Log "Changed directory to: $currentDir"
    
    # Start AUTOMATIC1111
    Write-Log "Starting AUTOMATIC1111..."
    Start-Process -FilePath "PowerShell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$startScript`"" -WorkingDirectory "$currentDir"
    Write-Log "AUTOMATIC1111 startup command executed"
    
} catch {
    Write-Log "ERROR: `$(`$_.Exception.Message)"
}
"@

$monitorScriptPath = Join-Path $currentDir "startup-monitor.ps1"
$monitorScript | Out-File -FilePath $monitorScriptPath -Encoding UTF8

Write-Host "`nSetup Summary:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host "✅ Task Name: $taskName" -ForegroundColor White
Write-Host "✅ Trigger: System Startup (2-minute delay)" -ForegroundColor White
Write-Host "✅ User: $env:USERNAME" -ForegroundColor White
Write-Host "✅ Working Directory: $currentDir" -ForegroundColor White
Write-Host "✅ Log Directory: $logPath" -ForegroundColor White
Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "View task:     Get-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host "Start now:     Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host "Stop task:     Stop-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host "Remove task:   Unregister-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host "View logs:     Get-Content '$logPath\startup-*.log'" -ForegroundColor White
Write-Host ""
Write-Host "AUTOMATIC1111 will now start automatically when your PC boots!" -ForegroundColor Green
Write-Host "It will be available at http://localhost:7860 after startup" -ForegroundColor Green