# Remove AUTOMATIC1111 Auto-Start
# Removes the Windows Task Scheduler task for AUTOMATIC1111

Write-Host "Removing AUTOMATIC1111 Auto-Start" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

$taskName = "AUTOMATIC1111-AutoStart"

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

try {
    # Check if task exists
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        # Remove the task
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "[OK] Removed auto-start task: $taskName" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Auto-start task not found: $taskName" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[ERROR] Failed to remove task: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Remove monitor script
$monitorScript = "startup-monitor.ps1"
if (Test-Path $monitorScript) {
    Remove-Item $monitorScript -Force
    Write-Host "[OK] Removed startup monitor script" -ForegroundColor Green
}

Write-Host ""
Write-Host "AUTOMATIC1111 auto-start has been disabled" -ForegroundColor Green