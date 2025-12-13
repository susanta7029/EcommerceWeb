# 🚀 AWS Master-Slave Infrastructure with Terraform, Puppet & Nagios

Complete Infrastructure-as-Code solution for deploying a master-slave architecture on AWS with automated configuration management and monitoring.

## 📋 What's Inside

This project provides:
- **1 Master Node**: Puppet Server + Nagios monitoring server
- **2 Slave Nodes**: Auto-configured workers with health monitoring
- **Full Automation**: Everything deployed via Terraform
- **Configuration Management**: Puppet for automated setup
- **Monitoring**: Nagios for CPU, memory, and disk monitoring

## ⚡ Quick Start

### 1. Prerequisites
- AWS Account with credentials configured
- Terraform installed (>= 1.0)
- AWS CLI installed

### 2. Deploy

```powershell
# Run the deployment script
.\deploy.ps1

# Or manually
cd terraform
terraform init
terraform apply
```

### 3. Access

After 5-10 minutes, access Nagios:
- **URL**: `http://<master_ip>/nagios`
- **Username**: `nagiosadmin`
- **Password**: `nagiosadmin` (change immediately!)

## 📚 Documentation

All documentation is in the `terraform/` directory:

- **[INDEX.md](terraform/INDEX.md)** - 📋 Documentation index and quick reference
- **[QUICKSTART.md](terraform/QUICKSTART.md)** - ⚡ 5-minute deployment guide
- **[SECURITY.md](terraform/SECURITY.md)** - 🔒 **READ THIS!** Security best practices
- **[README.md](terraform/README.md)** - 📖 Complete deployment guide
- **[ARCHITECTURE.md](terraform/ARCHITECTURE.md)** - 🏗️ Architecture details

## 🔒 Security Notice

**IMPORTANT**: This project handles SSH keys and credentials. Please:
1. ✅ Read [SECURITY.md](terraform/SECURITY.md) before deploying
2. ✅ Never commit private keys to version control
3. ✅ Change default passwords immediately after deployment
4. ✅ Restrict security groups to your IP address

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│  Master Node (Puppet + Nagios)         │
│  - Manages configuration                │
│  - Monitors health                      │
│  - Web dashboard                        │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
┌───▼─────┐      ┌──────▼────┐
│ Slave 1 │      │  Slave 2  │
│ (Worker)│      │  (Worker) │
└─────────┘      └───────────┘
```

## 💰 Cost

Approximate monthly cost (us-east-1):
- 1x t3.medium (master): ~$30/month
- 2x t3.small (slaves): ~$30/month
- **Total: ~$60/month**

Use `terraform destroy` when not needed to save costs.

## 🎯 Features

✅ **Fully Automated Deployment**
- One command to deploy entire infrastructure
- Auto-generated SSH keys (or use your own)
- Automatic service configuration

✅ **Configuration Management**
- Puppet Server on master
- Auto-signs certificates
- Configures all slaves automatically

✅ **Monitoring**
- Nagios Core with web interface
- Monitors CPU, memory, disk usage
- 5-minute check intervals
- Alert thresholds configured

✅ **Security**
- VPC with proper networking
- Security groups configured
- SSH key management
- .gitignore for sensitive files

## 🔧 Common Tasks

### Deploy Infrastructure
```powershell
.\deploy.ps1
```

### Access Master Node
```powershell
ssh -i private-key.pem ubuntu@<master_ip>
```

### View Monitoring
Open browser: `http://<master_ip>/nagios`

### Add More Slaves
Edit `terraform/terraform.tfvars`:
```hcl
slave_count = 3  # or any number
```
Then run: `terraform apply`

### Destroy Everything
```powershell
cd terraform
terraform destroy
```

## 📂 Project Structure

```
.
├── deploy.ps1              # Windows deployment script
├── README.md               # This file
└── terraform/              # Infrastructure code
    ├── main.tf             # Main infrastructure
    ├── variables.tf        # Variables
    ├── outputs.tf          # Outputs
    ├── key_pair.tf         # SSH key management
    ├── terraform.tfvars    # Your configuration
    ├── scripts/            # Initialization scripts
    ├── puppet/             # Puppet manifests
    └── *.md                # Documentation
```

## 🆘 Troubleshooting

### Deployment fails?
- Check AWS credentials: `aws sts get-caller-identity`
- Verify Terraform is installed: `terraform version`
- Review error messages in console output

### Can't access Nagios?
- Wait 5-10 minutes for services to start
- Check security group allows HTTP (port 80)
- Verify instance is running: `aws ec2 describe-instances`

### Puppet agents not connecting?
- Check master IP in slave configuration
- Verify port 8140 is open in security groups
- Sign certificates manually: See [QUICKSTART.md](terraform/QUICKSTART.md)

## 🤝 Contributing

This is a template project for infrastructure deployment. Feel free to:
- Customize for your needs
- Add more monitoring checks
- Implement additional security features
- Scale to more slaves

## 📄 License

This infrastructure template is provided as-is for educational and production use.

## 🔗 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Puppet Documentation](https://puppet.com/docs)
- [Nagios Documentation](https://www.nagios.org/documentation/)
- [AWS Best Practices](https://aws.amazon.com/architecture/well-architected/)

---

**Ready to deploy? Start with [QUICKSTART.md](terraform/QUICKSTART.md)! 🚀**
