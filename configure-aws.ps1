# AWS Credentials Setup Script
# Run this in PowerShell to configure AWS credentials

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  AWS Credentials Configuration  " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if AWS CLI is available
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Refreshing PATH..." -ForegroundColor Yellow
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    try {
        $awsVersion = aws --version 2>&1
        Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ AWS CLI not installed. Please run: winget install Amazon.AWSCLI" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "How to get AWS credentials:" -ForegroundColor Yellow
Write-Host "1. Go to: https://console.aws.amazon.com/" -ForegroundColor White
Write-Host "2. Click your username → Security credentials" -ForegroundColor White
Write-Host "3. Scroll to 'Access keys' → Create access key" -ForegroundColor White
Write-Host "4. Choose 'Command Line Interface (CLI)'" -ForegroundColor White
Write-Host "5. Copy the Access Key ID and Secret Access Key" -ForegroundColor White
Write-Host ""

# Prompt for credentials
$accessKeyId = Read-Host "Enter your AWS Access Key ID"
$secretAccessKey = Read-Host "Enter your AWS Secret Access Key" -AsSecureString
$secretAccessKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretAccessKey)
)

$region = Read-Host "Enter your preferred AWS region (default: us-east-1)"
if ([string]::IsNullOrWhiteSpace($region)) {
    $region = "us-east-1"
}

# Create .aws directory if it doesn't exist
$awsDir = "$env:USERPROFILE\.aws"
if (-not (Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir | Out-Null
    Write-Host "✓ Created .aws directory" -ForegroundColor Green
}

# Write credentials file
$credentialsContent = @"
[default]
aws_access_key_id = $accessKeyId
aws_secret_access_key = $secretAccessKeyPlain
"@

Set-Content -Path "$awsDir\credentials" -Value $credentialsContent
Write-Host "✓ Credentials file created" -ForegroundColor Green

# Write config file
$configContent = @"
[default]
region = $region
output = json
"@

Set-Content -Path "$awsDir\config" -Value $configContent
Write-Host "✓ Config file created" -ForegroundColor Green

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "  Configuration Complete!         " -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# Verify configuration
Write-Host "Verifying AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ AWS credentials are valid!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your AWS Identity:" -ForegroundColor Cyan
        Write-Host $identity
        Write-Host ""
        Write-Host "==================================" -ForegroundColor Cyan
        Write-Host "  Ready to Deploy!                " -ForegroundColor Cyan
        Write-Host "==================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. cd terraform" -ForegroundColor White
        Write-Host "2. terraform plan" -ForegroundColor White
        Write-Host "3. terraform apply" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✗ Error verifying credentials:" -ForegroundColor Red
        Write-Host $identity
        Write-Host ""
        Write-Host "Please check your Access Key ID and Secret Access Key" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error verifying credentials: $_" -ForegroundColor Red
}
