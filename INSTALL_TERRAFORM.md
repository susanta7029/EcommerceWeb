# 🔧 Install Terraform on Windows

## Quick Installation Methods

### Option 1: Using Chocolatey (Recommended - Easiest)

If you have Chocolatey installed:

```powershell
# Run PowerShell as Administrator
choco install terraform
```

### Option 2: Using winget (Windows Package Manager)

If you have winget (Windows 10/11):

```powershell
# Run in PowerShell
winget install Hashicorp.Terraform
```

### Option 3: Manual Installation

1. **Download Terraform:**
   - Go to: https://www.terraform.io/downloads
   - Download the Windows AMD64 version (ZIP file)

2. **Extract the ZIP:**
   - Extract `terraform.exe` to a folder, e.g., `C:\terraform\`

3. **Add to PATH:**
   ```powershell
   # Run PowerShell as Administrator
   
   # Add Terraform to PATH permanently
   $terraformPath = "C:\terraform"
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
   [Environment]::SetEnvironmentVariable("Path", "$currentPath;$terraformPath", "Machine")
   
   # Refresh environment variables in current session
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

4. **Verify Installation:**
   ```powershell
   # Close and reopen PowerShell, then run:
   terraform version
   ```

## After Installation

Once Terraform is installed, navigate to the terraform directory and run:

```powershell
cd C:\Users\susan\Desktop\Ecommerce-Web-App-main\terraform
terraform init
terraform validate
terraform plan
```

## Check if Chocolatey is Installed

```powershell
choco --version
```

If not installed, install Chocolatey first:

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Quick Install Script

Save this as `install-terraform.ps1` and run as Administrator:

```powershell
# Check if Terraform is already installed
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host "✅ Terraform is already installed!" -ForegroundColor Green
    terraform version
    exit
}

Write-Host "Installing Terraform..." -ForegroundColor Yellow

# Try winget first
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Installing via winget..." -ForegroundColor Cyan
    winget install Hashicorp.Terraform
    Write-Host "✅ Terraform installed successfully!" -ForegroundColor Green
    exit
}

# Try Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Installing via Chocolatey..." -ForegroundColor Cyan
    choco install terraform -y
    Write-Host "✅ Terraform installed successfully!" -ForegroundColor Green
    exit
}

# Manual installation
Write-Host "Please install Terraform manually from: https://www.terraform.io/downloads" -ForegroundColor Yellow
Write-Host "Or install Chocolatey first and run this script again." -ForegroundColor Yellow
```

## Verify Installation

After installation, verify with:

```powershell
terraform version
```

You should see output like:
```
Terraform v1.x.x
on windows_amd64
```

## Troubleshooting

### "terraform not recognized" after installation

1. Close and reopen PowerShell
2. Or refresh PATH in current session:
   ```powershell
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

### Still not working?

Check if terraform.exe exists:
```powershell
Get-Command terraform -ErrorAction SilentlyContinue
```

If not found, check your PATH:
```powershell
$env:Path -split ';'
```

---

**Once Terraform is installed, you can proceed with the deployment!** 🚀
