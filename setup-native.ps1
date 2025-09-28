# AUTOMATIC1111 Native Windows Setup
# Simple, no-Docker installation with Python virtual environment isolation

Write-Host "AUTOMATIC1111 Native Windows Setup" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Check Python 3.10.x (AUTOMATIC1111 recommended version)
Write-Host "`nChecking Python installation..." -ForegroundColor Yellow

# Check common Python 3.10 installation paths
$pythonPaths = @(
    "python",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python310\python.exe",
    "C:\Python310\python.exe",
    "py -3.10"
)

$pythonFound = $false
$pythonExe = ""

foreach ($pythonPath in $pythonPaths) {
    try {
        $pythonVersion = & $pythonPath --version 2>&1
        if ($pythonVersion -match "Python 3\.10\.") {
            Write-Host "[OK] Found Python 3.10: $pythonVersion" -ForegroundColor Green
            Write-Host "[OK] Using: $pythonPath" -ForegroundColor Green
            $pythonFound = $true
            $pythonExe = $pythonPath
            break
        }
    } catch {
        # Continue to next path
    }
}

if (-not $pythonFound) {
    Write-Host "[ERROR] Python 3.10.x not found in standard locations" -ForegroundColor Red
    Write-Host "Python 3.10 appears to be installed but not accessible" -ForegroundColor Yellow
    Write-Host "Try reinstalling Python 3.10.6 with 'Add to PATH' checked:" -ForegroundColor Yellow
    Write-Host "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -ForegroundColor Cyan
    exit 1
}

# Check Git
Write-Host "`nChecking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "[OK] $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git not found. Install from:" -ForegroundColor Red
    Write-Host "https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Clone AUTOMATIC1111 repository
Write-Host "`nDownloading AUTOMATIC1111..." -ForegroundColor Yellow
if (-not (Test-Path "webui")) {
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git webui
    Write-Host "[OK] Repository cloned" -ForegroundColor Green
} else {
    Write-Host "[OK] Repository already exists" -ForegroundColor Green
}

# Create directories
Write-Host "`nCreating directories..." -ForegroundColor Yellow
$directories = @("data\models", "data\output")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "[OK] Created: $dir" -ForegroundColor Green
    }
}

# Configure AUTOMATIC1111 with API enabled
Write-Host "`nConfiguring AUTOMATIC1111..." -ForegroundColor Yellow
$webuiConfig = @"
@echo off

set PYTHON=$pythonExe
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=--listen --api --port 7860 --enable-insecure-extension-access --api-log --cors-allow-origins=*

call webui.bat
"@

$webuiConfig | Out-File -FilePath "webui\webui-user.bat" -Encoding ASCII
Write-Host "[OK] Configuration created with Swagger API enabled" -ForegroundColor Green

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green
Write-Host ""
Write-Host "To start AUTOMATIC1111:" -ForegroundColor Cyan
Write-Host "   cd webui" -ForegroundColor White
Write-Host "   .\webui-user.bat" -ForegroundColor White
Write-Host ""
Write-Host "WebUI will be available at:" -ForegroundColor Cyan
Write-Host "   http://localhost:7860" -ForegroundColor White
Write-Host ""
Write-Host "Swagger API Documentation:" -ForegroundColor Cyan
Write-Host "   http://localhost:7860/docs" -ForegroundColor White
Write-Host ""
Write-Host "Key API endpoints:" -ForegroundColor Cyan
Write-Host "   POST /sdapi/v1/txt2img" -ForegroundColor White
Write-Host "   POST /sdapi/v1/img2img" -ForegroundColor White
Write-Host ""
Write-Host "Benefits:" -ForegroundColor Yellow
Write-Host "   * Isolated Python virtual environment (automatic)"
Write-Host "   * Easy updates (git pull in webui folder)"
Write-Host "   * Full Swagger/OpenAPI interface"
Write-Host "   * Native Windows performance"
Write-Host "   * No Docker complexity"