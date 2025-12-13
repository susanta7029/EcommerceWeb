# Quick Start Deployment Script for Windows PowerShell
# This script helps you deploy the infrastructure quickly

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Master-Slave Infrastructure Deployer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Terraform is installed
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
try {
    $terraformVersion = terraform version
    Write-Host "✓ Terraform is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform is not installed!" -ForegroundColor Red
    Write-Host "Please install Terraform from: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version
    Write-Host "✓ AWS CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI is not installed!" -ForegroundColor Red
    Write-Host "Please install AWS CLI from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AWS Configuration" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Prompt for AWS region
$region = Read-Host "Enter AWS region (default: us-east-1)"
if ([string]::IsNullOrWhiteSpace($region)) {
    $region = "us-east-1"
}

# Prompt for key pair name
Write-Host ""
Write-Host "SSH Key Configuration:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Choose an option:" -ForegroundColor Cyan
Write-Host "  1. Let Terraform create a new key pair (Recommended)" -ForegroundColor White
Write-Host "  2. Use an existing AWS EC2 key pair" -ForegroundColor White
Write-Host ""
$keyOption = Read-Host "Enter your choice (1 or 2)"

$createNewKey = $true
$keyName = ""

if ($keyOption -eq "2") {
    $createNewKey = $false
    Write-Host ""
    Write-Host "Enter your existing AWS EC2 key pair name:" -ForegroundColor Yellow
    $keyName = Read-Host "Key pair name"
    
    if ([string]::IsNullOrWhiteSpace($keyName)) {
        Write-Host "Error: Key pair name is required!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "Terraform will create a new SSH key pair automatically." -ForegroundColor Green
    Write-Host "The private key will be saved to terraform/private-key.pem" -ForegroundColor Yellow
}

# Prompt for instance types
Write-Host ""
$masterType = Read-Host "Master instance type (default: t3.medium)"
if ([string]::IsNullOrWhiteSpace($masterType)) {
    $masterType = "t3.medium"
}

$slaveType = Read-Host "Slave instance type (default: t3.small)"
if ([string]::IsNullOrWhiteSpace($slaveType)) {
    $slaveType = "t3.small"
}

$slaveCount = Read-Host "Number of slave nodes (default: 2)"
if ([string]::IsNullOrWhiteSpace($slaveCount)) {
    $slaveCount = "2"
}

# Create terraform.tfvars
Write-Host ""
Write-Host "Creating terraform.tfvars..." -ForegroundColor Yellow

if ($createNewKey) {
    $tfvarsContent = @"
# AWS Region
aws_region = "$region"

# Project name
project_name = "master-slave-infra"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# Instance types
master_instance_type = "$masterType"
slave_instance_type  = "$slaveType"

# Number of slave nodes
slave_count = $slaveCount

# SSH Key Configuration
create_new_key = true
"@
} else {
    $tfvarsContent = @"
# AWS Region
aws_region = "$region"

# Project name
project_name = "master-slave-infra"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# Instance types
master_instance_type = "$masterType"
slave_instance_type  = "$slaveType"

# Number of slave nodes
slave_count = $slaveCount

# SSH Key Configuration
create_new_key = false
key_name = "$keyName"
"@
}

Set-Content -Path "terraform\terraform.tfvars" -Value $tfvarsContent
Write-Host "✓ terraform.tfvars created" -ForegroundColor Green

# Navigate to terraform directory
Set-Location -Path "terraform"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Terraform Initialization" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Initialize Terraform
Write-Host "Running: terraform init" -ForegroundColor Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform initialization failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Terraform initialized successfully" -ForegroundColor Green
Write-Host ""

# Plan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Terraform Plan" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Running: terraform plan" -ForegroundColor Yellow
terraform plan

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Terraform plan failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Ready to Deploy" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Yellow
Write-Host "  Region:        $region" -ForegroundColor White
Write-Host "  Master Type:   $masterType" -ForegroundColor White
Write-Host "  Slave Type:    $slaveType" -ForegroundColor White
Write-Host "  Slave Count:   $slaveCount" -ForegroundColor White
if ($createNewKey) {
    Write-Host "  SSH Key:       Auto-generated by Terraform" -ForegroundColor White
} else {
    Write-Host "  SSH Key:       $keyName (existing)" -ForegroundColor White
}
Write-Host ""

$confirm = Read-Host "Do you want to deploy? (yes/no)"

if ($confirm -eq "yes") {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Deploying Infrastructure" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Running: terraform apply -auto-approve" -ForegroundColor Yellow
    
    terraform apply -auto-approve
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "Deployment Successful!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: Wait 5-10 minutes for services to initialize" -ForegroundColor Yellow
        Write-Host ""
        
        if ($createNewKey) {
            Write-Host "🔐 SECURE YOUR PRIVATE KEY NOW!" -ForegroundColor Red
            Write-Host ""
            Write-Host "Your private key is at: terraform\private-key.pem" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Run these commands to secure it:" -ForegroundColor Cyan
            Write-Host "  icacls terraform\private-key.pem /inheritance:r" -ForegroundColor White
            Write-Host "  icacls terraform\private-key.pem /grant:r `"`$(`$env:USERNAME):(R)`"" -ForegroundColor White
            Write-Host ""
            Write-Host "Or move to secure location:" -ForegroundColor Cyan
            Write-Host "  Move-Item terraform\private-key.pem ~\.ssh\infrastructure-key.pem" -ForegroundColor White
            Write-Host ""
        }
        
        Write-Host "Access Nagios at the URL shown above" -ForegroundColor Cyan
        Write-Host "Default credentials:" -ForegroundColor Cyan
        Write-Host "  Username: nagiosadmin" -ForegroundColor White
        Write-Host "  Password: nagiosadmin" -ForegroundColor White
        Write-Host ""
        Write-Host "SECURITY: Change the default password immediately!" -ForegroundColor Red
        Write-Host ""
        Write-Host "📚 Next Steps:" -ForegroundColor Yellow
        Write-Host "  1. Secure your private key (see commands above)" -ForegroundColor White
        Write-Host "  2. Wait 5-10 minutes for services to start" -ForegroundColor White
        Write-Host "  3. Access Nagios web interface" -ForegroundColor White
        Write-Host "  4. Change default password" -ForegroundColor White
        Write-Host "  5. Read SECURITY.md for best practices" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✗ Deployment failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    Write-Host "You can deploy later by running:" -ForegroundColor Yellow
    Write-Host "  cd terraform" -ForegroundColor White
    Write-Host "  terraform apply" -ForegroundColor White
}

Set-Location -Path ".."
