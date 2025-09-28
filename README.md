# AUTOMATIC1111 - Simple Windows Setup

Clean, native installation of Stable Diffusion WebUI without Docker complexity.

## 🚀 Quick Start

1. **Install Requirements**
   - Python 3.10.x: https://www.python.org/downloads/release/python-3106/
   - Git: https://git-scm.com/download/win

2. **Setup AUTOMATIC1111**
   ```powershell
   .\setup-native.ps1
   ```

3. **Start the Service**
   ```powershell
   .\start.ps1
   ```

4. **Access the Interface**
   - 🎨 **Web UI**: http://localhost:7860
   - 📋 **Swagger API**: http://localhost:7860/docs

## ✨ What You Get

- ✅ **Isolated Environment** - Automatic Python virtual environment
- ✅ **Easy Updates** - Simple `git pull` in webui folder
- ✅ **Full API Access** - Complete Swagger/OpenAPI interface at `/docs`
- ✅ **Native Performance** - No Docker overhead or complexity
- ✅ **GPU Acceleration** - Automatic CUDA detection and setup
- ✅ **Auto-Start Ready** - Boot with Windows (one-time admin setup)
- ✅ **Smart Python Detection** - Finds Python 3.10 in standard locations
- ✅ **Background Operation** - Runs hidden, accessible via browser

## 📋 Requirements

| Component | Version | Download Link |
|-----------|---------|---------------|
| Windows | 10/11 | - |
| Python | 3.10.x | [Download](https://www.python.org/downloads/release/python-3106/) |
| Git | Latest | [Download](https://git-scm.com/download/win) |
| Storage | 25GB+ | - |
| GPU | NVIDIA (optional) | Latest drivers recommended |

## 🔧 Management Commands

```powershell
# Start AUTOMATIC1111 manually
.\start.ps1

# Setup auto-start with Windows (ONE-TIME, requires Admin)
# Right-click PowerShell -> "Run as Administrator"
.\setup-autostart.ps1

# Remove auto-start (requires Admin)
.\remove-autostart.ps1

# Update AUTOMATIC1111
cd webui
git pull

# Check auto-start task status
Get-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart"

# Test auto-start manually
Start-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart"

# View startup logs (from project directory)
cd C:\Projects\automatic1111
Get-Content logs\startup-*.log

# Check if AUTOMATIC1111 is running
Get-Process python -ErrorAction SilentlyContinue
```

## 📁 Project Structure

```
automatic1111/
├── webui/                    # AUTOMATIC1111 installation (created by setup)
│   ├── venv/                # Python virtual environment (auto-created)
│   ├── models/              # AI models directory
│   ├── outputs/             # Generated images
│   └── webui-user.bat       # Configuration file (auto-generated)
├── data/
│   ├── models/              # Convenient models directory
│   └── output/              # Convenient outputs directory  
├── logs/                    # Auto-start logs (created when needed)
├── setup-native.ps1         # Main installation script
├── start.ps1               # Manual startup script
├── setup-autostart.ps1     # Auto-start setup (requires admin)
├── remove-autostart.ps1    # Remove auto-start (requires admin)
└── README.md               # This comprehensive guide
```

## 🌐 API Documentation

### Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/sdapi/v1/txt2img` | POST | Generate images from text |
| `/sdapi/v1/img2img` | POST | Transform existing images |
| `/sdapi/v1/options` | GET | Get current settings |
| `/sdapi/v1/samplers` | GET | List available samplers |
| `/sdapi/v1/sd-models` | GET | List available models |

### Example API Usage

```powershell
# Text-to-Image API call
$headers = @{"Content-Type" = "application/json"}
$body = @{
    prompt = "a beautiful landscape, 4k, highly detailed"
    steps = 20
    width = 512
    height = 512
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:7860/sdapi/v1/txt2img" -Method POST -Headers $headers -Body $body
```

## 🎯 Models

### Adding Models

1. **Download models** to `data\models\` folder
2. **Restart AUTOMATIC1111** to detect new models
3. **Select model** in Web UI or via API

### Popular Models

- **Stable Diffusion 1.5** - General purpose, well-supported
- **Stable Diffusion XL** - Higher quality, larger images  
- **Custom models** - From [Civitai](https://civitai.com/), [Hugging Face](https://huggingface.co/)

### Model Sources

| Source | Description | Link |
|--------|-------------|------|
| Civitai | Community models | https://civitai.com/ |
| Hugging Face | Official & community | https://huggingface.co/models |
| Official SD | Base models | https://huggingface.co/runwayml |

## 🔧 Configuration

### Auto-Start Configuration

**Setup (One-time, requires Administrator):**
```powershell
# Right-click PowerShell -> "Run as Administrator"
.\setup-autostart.ps1
```

**What it does:**
- Creates Windows Task Scheduler entry
- Starts AUTOMATIC1111 automatically 2 minutes after boot
- Runs in background (hidden window)
- Available at http://localhost:7860 after startup
- Logs startup process to `logs\startup-YYYY-MM-DD.log`

### Custom Settings

Edit `webui\webui-user.bat` to modify:

```batch
set COMMANDLINE_ARGS=--listen --api --port 7860 --enable-insecure-extension-access --api-log --cors-allow-origins=*
```

### Common Arguments

| Argument | Description |
|----------|-------------|
| `--listen` | Allow external connections |
| `--api` | Enable API and Swagger docs |
| `--port 7860` | Set port number |
| `--medvram` | Optimize for 4-8GB VRAM |
| `--lowvram` | Optimize for <4GB VRAM |
| `--no-half` | Disable half precision (compatibility) |

## 🚨 Troubleshooting

### Auto-Start Issues

**Task not running after reboot:**
```powershell
# Check task status
Get-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart"

# Check task history
Get-WinEvent -FilterHashtable @{LogName="Microsoft-Windows-TaskScheduler/Operational"; ID=200,201} | Where-Object {$_.Message -like "*AUTOMATIC1111*"}

# Test manually
Start-ScheduledTask -TaskName "AUTOMATIC1111-AutoStart"
```

**Auto-start setup fails:**
- Must run PowerShell as Administrator
- Windows Task Scheduler service must be running
- User account must have task scheduling permissions

**Logs not found:**
```powershell
# Always navigate to project directory first
cd C:\Projects\automatic1111
Get-Content logs\startup-*.log
```

### Common Issues

**Port already in use:**
```powershell
# Check what's using port 7860
netstat -ano | findstr :7860

# Kill process if needed
taskkill /PID [PID_NUMBER] /F
```

**Python not found during setup:**
- Ensure Python 3.10.x is installed (not 3.11+ or 3.13+)
- Verify installation path in script output
- Reinstall Python with "Add to PATH" checked
- Script checks: `C:\Users\USERNAME\AppData\Local\Programs\Python\Python310\python.exe`

**GPU not detected:**
- Install latest NVIDIA drivers
- Check CUDA compatibility
- Use `--medvram` or `--lowvram` if needed

**Out of memory:**
- Reduce image resolution
- Use `--medvram` or `--lowvram`
- Close other GPU applications

**AUTOMATIC1111 won't start:**
```powershell
# Check if Python processes are running
Get-Process python -ErrorAction SilentlyContinue

# Check webui directory exists
Test-Path webui

# Re-run setup if webui missing
.\setup-native.ps1
```

### Getting Help

- **AUTOMATIC1111 Wiki**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki
- **Community**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions
- **Issues**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues

## 📜 License

This setup configuration is provided as-is. AUTOMATIC1111 and its components have their own licenses.

---

**🎨 Happy generating!** Your Stable Diffusion WebUI is ready with full API access and Swagger documentation.