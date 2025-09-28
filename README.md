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
- ✅ **Full API Access** - Complete Swagger/OpenAPI interface
- ✅ **Native Performance** - No Docker overhead or complexity
- ✅ **GPU Acceleration** - Automatic CUDA detection and setup
- ✅ **Auto-Start Option** - Boot with Windows capability

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
# Start AUTOMATIC1111
.\start.ps1

# Setup auto-start with Windows (requires Admin)
.\setup-autostart.ps1

# Remove auto-start
.\remove-autostart.ps1

# Update AUTOMATIC1111
cd webui
git pull

# View startup logs
Get-Content logs\startup-*.log
```

## 📁 Project Structure

```
automatic1111/
├── webui/                    # AUTOMATIC1111 installation
│   ├── venv/                # Python virtual environment
│   ├── models/              # AI models directory
│   ├── outputs/             # Generated images
│   └── webui-user.bat       # Configuration file
├── data/
│   ├── models/              # Symlink to webui/models
│   └── output/              # Symlink to webui/outputs
├── logs/                    # Startup and error logs
├── setup-native.ps1         # Main installation script
├── start.ps1               # Startup script
├── setup-autostart.ps1     # Auto-start setup
├── remove-autostart.ps1    # Remove auto-start
└── README.md               # This file
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

### Common Issues

**Port already in use:**
```powershell
# Check what's using port 7860
netstat -ano | findstr :7860

# Kill process if needed
taskkill /PID [PID_NUMBER] /F
```

**Python not found:**
- Ensure Python 3.10.x is installed
- Verify installation path in script output
- Reinstall Python with "Add to PATH" checked

**GPU not detected:**
- Install latest NVIDIA drivers
- Check CUDA compatibility
- Use `--medvram` or `--lowvram` if needed

**Out of memory:**
- Reduce image resolution
- Use `--medvram` or `--lowvram`
- Close other GPU applications

### Getting Help

- **AUTOMATIC1111 Wiki**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki
- **Community**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions
- **Issues**: https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues

## 📜 License

This setup configuration is provided as-is. AUTOMATIC1111 and its components have their own licenses.

---

**🎨 Happy generating!** Your Stable Diffusion WebUI is ready with full API access and Swagger documentation.