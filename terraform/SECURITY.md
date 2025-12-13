# 🔒 SECURITY WARNING AND GUIDE

## ⚠️ CRITICAL: Private Key Exposure

**IF YOU POSTED YOUR PRIVATE KEY PUBLICLY, TAKE IMMEDIATE ACTION:**

1. **Delete the compromised key pair from AWS immediately:**
   ```powershell
   aws ec2 delete-key-pair --key-name <your-compromised-key-name>
   ```

2. **Terminate any instances using that key:**
   ```powershell
   aws ec2 terminate-instances --instance-ids <instance-ids>
   ```

3. **Check AWS CloudTrail for unauthorized access**

4. **Rotate all credentials and secrets**

## ✅ Secure Key Management Options

### Option 1: Terraform-Generated Keys (Recommended for Testing)

The configuration now automatically creates a new SSH key pair:

```hcl
# In terraform.tfvars
create_new_key = true
```

**Deployment:**
```powershell
cd terraform
terraform init
terraform apply
```

**After deployment:**
- Private key saved to: `terraform/private-key.pem`
- **Immediately secure this file:**
  ```powershell
  # Set restrictive permissions
  icacls private-key.pem /inheritance:r
  icacls private-key.pem /grant:r "$($env:USERNAME):(R)"
  ```

- **Move to secure location:**
  ```powershell
  Move-Item private-key.pem ~\.ssh\infrastructure-key.pem
  ```

### Option 2: Use Existing AWS Key Pair (Recommended for Production)

1. **Create key pair in AWS Console:**
   - Go to: EC2 → Key Pairs → Create key pair
   - Name: `infrastructure-key`
   - Type: RSA
   - Format: .pem
   - Download and secure the .pem file

2. **Configure Terraform:**
   ```hcl
   # In terraform.tfvars
   create_new_key = false
   key_name = "infrastructure-key"
   ```

3. **Secure the downloaded key:**
   ```powershell
   Move-Item ~/Downloads/infrastructure-key.pem ~\.ssh\
   icacls ~\.ssh\infrastructure-key.pem /inheritance:r
   icacls ~\.ssh\infrastructure-key.pem /grant:r "$($env:USERNAME):(R)"
   ```

### Option 3: Import Your Own Public Key

If you have an existing key pair:

```powershell
# Generate new key pair locally
ssh-keygen -t rsa -b 4096 -f ~/.ssh/infrastructure-key -C "infrastructure@mycompany.com"

# Import public key to AWS
aws ec2 import-key-pair --key-name infrastructure-key --public-key-material fileb://~/.ssh/infrastructure-key.pub

# Configure Terraform
# In terraform.tfvars:
# create_new_key = false
# key_name = "infrastructure-key"
```

## 🛡️ Security Best Practices

### 1. Never Store Private Keys in Code

**DO NOT:**
- ❌ Paste private keys in code
- ❌ Commit .pem files to Git
- ❌ Share keys via email/chat
- ❌ Store keys in plain text

**DO:**
- ✅ Use `.gitignore` to exclude keys
- ✅ Use AWS Secrets Manager for production
- ✅ Use AWS Systems Manager Session Manager (no keys needed!)
- ✅ Rotate keys regularly

### 2. Restrict Key Permissions

**Windows:**
```powershell
icacls <key-file>.pem /inheritance:r
icacls <key-file>.pem /grant:r "$($env:USERNAME):(R)"
```

**Linux/Mac:**
```bash
chmod 400 <key-file>.pem
```

### 3. Use AWS Systems Manager Session Manager (No SSH Keys!)

Enable Session Manager for keyless access:

```hcl
# Add to main.tf
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Add to EC2 instances:
resource "aws_instance" "master" {
  # ... other settings ...
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}
```

Then connect without keys:
```powershell
aws ssm start-session --target <instance-id>
```

### 4. Secure Security Groups

Restrict SSH access to your IP only:

```hcl
# In main.tf, update master security group
resource "aws_security_group" "master" {
  # ... other settings ...
  
  # SSH access - RESTRICT TO YOUR IP!
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"]  # Replace with your IP
  }
}
```

Get your IP:
```powershell
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

### 5. Enable MFA for AWS Account

Always use Multi-Factor Authentication for your AWS account.

### 6. Use AWS Secrets Manager for Production

For production environments:

```hcl
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name = "${var.project_name}-ssh-private-key"
  
  recovery_window_in_days = 0  # For testing; use 30 for production
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.ssh_key[0].private_key_pem
}
```

Retrieve securely:
```powershell
aws secretsmanager get-secret-value --secret-id <secret-name> --query SecretString --output text > private-key.pem
icacls private-key.pem /inheritance:r
icacls private-key.pem /grant:r "$($env:USERNAME):(R)"
```

## 🔍 Security Checklist

Before deploying:
- [ ] Private keys are NOT in version control
- [ ] `.gitignore` includes `*.pem` and `*.key`
- [ ] SSH access restricted to your IP
- [ ] MFA enabled on AWS account
- [ ] Using latest AMIs (auto-patching enabled)
- [ ] Security groups follow least-privilege principle
- [ ] Default passwords changed (Nagios)
- [ ] HTTPS enabled for web interfaces
- [ ] Monitoring and alerting configured
- [ ] Backup strategy in place

After deployment:
- [ ] Change default Nagios password
- [ ] Test SSH access
- [ ] Verify security group rules
- [ ] Enable AWS CloudTrail
- [ ] Enable AWS Config
- [ ] Set up AWS GuardDuty
- [ ] Configure automated backups
- [ ] Document access procedures
- [ ] Schedule regular security audits

## 📞 Incident Response

If you suspect key compromise:

1. **Immediately revoke the key:**
   ```powershell
   aws ec2 delete-key-pair --key-name <key-name>
   ```

2. **Check CloudTrail logs:**
   ```powershell
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=<username>
   ```

3. **Rotate credentials:**
   - Generate new key pair
   - Update instances with new key
   - Update Terraform state

4. **Review access logs:**
   ```bash
   # On instances
   sudo lastlog
   sudo cat /var/log/auth.log | grep "Accepted publickey"
   ```

## 📚 Additional Resources

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [Terraform Security Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)

## 🔐 Password Security

**Default credentials that MUST be changed:**

1. **Nagios Web Interface:**
   ```bash
   # On master node
   sudo htpasswd /usr/local/nagios/etc/htpasswd.users nagiosadmin
   ```

2. **Never use:**
   - Default passwords
   - Weak passwords
   - Same passwords across systems
   - Passwords in environment variables

**Use strong passwords:**
- Minimum 16 characters
- Mix of letters, numbers, symbols
- Unique per service
- Stored in password manager

---

**Remember: Security is not a one-time setup, it's an ongoing process!**
