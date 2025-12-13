# Quick AWS Configuration Guide

## Problem: AWS CLI not recognized after installation

**Solution:** Refresh your PowerShell PATH or open a new PowerShell window.

## Step-by-Step Setup

### Option 1: Run the Configuration Script (Easiest)

```powershell
# Navigate to project directory
cd C:\Users\susan\Desktop\Ecommerce-Web-App-main

# Run the configuration script
.\configure-aws.ps1
```

The script will prompt you for:
- AWS Access Key ID
- AWS Secret Access Key
- AWS Region (default: us-east-1)

### Option 2: Manual Configuration

#### Step 1: Create AWS Directory

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.aws" -Force
```

#### Step 2: Create Credentials File

```powershell
# Edit this file: C:\Users\susan\.aws\credentials
notepad $env:USERPROFILE\.aws\credentials
```

Add this content (replace with your actual keys):
```
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

#### Step 3: Create Config File

```powershell
# Edit this file: C:\Users\susan\.aws\config
notepad $env:USERPROFILE\.aws\config
```

Add this content:
```
[default]
region = us-east-1
output = json
```

#### Step 4: Verify Configuration

```powershell
# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Test AWS CLI
aws --version

# Verify credentials
aws sts get-caller-identity
```

If successful, you'll see your AWS account information!

### Option 3: Use AWS Configure Command

Open a **NEW PowerShell window** (this ensures PATH is updated), then:

```powershell
aws configure
```

You'll be prompted for:
```
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

## How to Get AWS Access Keys

1. **Login to AWS Console**: https://console.aws.amazon.com/
2. Click your **username** (top right) → **Security credentials**
3. Scroll to **Access keys** section
4. Click **Create access key**
5. Select **Command Line Interface (CLI)**
6. Click **Next** → **Create access key**
7. **IMPORTANT**: Download or copy both:
   - Access key ID (starts with `AKIA...`)
   - Secret access key (you won't see this again!)

## Troubleshooting

### "aws: command not found"

**Solution 1**: Open a new PowerShell window

**Solution 2**: Refresh PATH in current window:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### "Unable to locate credentials"

Your credentials file is missing or incorrect.

**Fix**: Create the files manually as shown in Option 2 above.

### "The security token is invalid"

Your access keys are incorrect or expired.

**Fix**: 
1. Go to AWS Console → Security credentials
2. Delete the old access key
3. Create a new access key
4. Update your credentials file

## Verify Everything is Working

```powershell
# Check AWS CLI version
aws --version

# Verify credentials
aws sts get-caller-identity

# List S3 buckets (if you have any)
aws s3 ls

# Check current region
aws configure get region
```

## After AWS is Configured

```powershell
cd C:\Users\susan\Desktop\Ecommerce-Web-App-main\terraform

# Review deployment plan
terraform plan

# Deploy infrastructure (will prompt for confirmation)
terraform apply
```

---

## Quick Commands Reference

```powershell
# Open new PowerShell as Administrator
# Then navigate to project:
cd C:\Users\susan\Desktop\Ecommerce-Web-App-main

# Option A: Use the script
.\configure-aws.ps1

# Option B: Use AWS configure (open new PowerShell first!)
aws configure

# Option C: Manual setup
notepad $env:USERPROFILE\.aws\credentials
notepad $env:USERPROFILE\.aws\config
```

**Choose whichever option is easiest for you!** 🚀
