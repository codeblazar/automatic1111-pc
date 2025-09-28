# AUTOMATIC1111 Startup Script
# Starts the WebUI with API enabled

Write-Host "Starting AUTOMATIC1111..." -ForegroundColor Green

if (-not (Test-Path "webui")) {
    Write-Host "[ERROR] AUTOMATIC1111 not installed. Run setup-native.ps1 first" -ForegroundColor Red
    exit 1
}

Set-Location "webui"
.\webui-user.bat