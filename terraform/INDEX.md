# 📋 Master-Slave Infrastructure - Complete Documentation Index

Welcome! This directory contains everything you need to deploy and manage a master-slave architecture on AWS with Puppet and Nagios monitoring.

## 🎯 Start Here

### First Time Users
1. **[QUICKSTART.md](QUICKSTART.md)** - ⚡ 5-minute deployment guide
2. **[SECURITY.md](SECURITY.md)** - 🔒 **READ THIS FIRST!** Critical security information

### Detailed Documentation
3. **[README.md](README.md)** - 📖 Complete deployment and usage guide
4. **[ARCHITECTURE.md](ARCHITECTURE.md)** - 🏗️ Architecture diagrams and technical details

## 📁 File Structure

```
terraform/
├── 📄 Documentation
│   ├── INDEX.md (this file)     # Documentation index
│   ├── QUICKSTART.md            # Fast deployment guide
│   ├── README.md                # Complete guide
│   ├── SECURITY.md              # Security best practices ⚠️
│   └── ARCHITECTURE.md          # Architecture details
│
├── ⚙️ Terraform Configuration
│   ├── main.tf                  # Main infrastructure
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   ├── key_pair.tf              # SSH key management
│   └── terraform.tfvars         # Your settings (customize!)
│
├── 🔧 Scripts
│   └── scripts/
│       ├── master_init.sh       # Master node setup
│       └── slave_init.sh        # Slave node setup
│
├── 🎭 Puppet Configuration
│   └── puppet/
│       ├── site.pp              # Puppet manifest
│       └── nrpe.cfg.erb         # NRPE config template
│
└── 🛡️ Security
    └── .gitignore               # Prevents committing secrets
```

## 🚀 Quick Actions

### Deploy Infrastructure
```powershell
# Automated deployment
.\deploy.ps1

# Or manual
cd terraform
terraform init
terraform apply
```

### Connect to Instances
```powershell
# Master (Puppet + Nagios)
ssh -i private-key.pem ubuntu@<master_ip>

# Slave
ssh -i private-key.pem ubuntu@<slave_ip>
```

### Access Nagios
```
URL: http://<master_ip>/nagios
Username: nagiosadmin
Password: nagiosadmin (CHANGE THIS!)
```

### Destroy Everything
```powershell
cd terraform
terraform destroy
```

## 📚 Documentation by Task

### Planning & Setup
- **Understanding the architecture** → [ARCHITECTURE.md](ARCHITECTURE.md)
- **Quick deployment** → [QUICKSTART.md](QUICKSTART.md)
- **Detailed setup** → [README.md](README.md) (Setup Instructions)
- **Security configuration** → [SECURITY.md](SECURITY.md)

### Day-to-Day Operations
- **Managing Puppet** → [README.md](README.md) (Puppet Management)
- **Using Nagios** → [README.md](README.md) (Nagios Monitoring)
- **SSH access** → [README.md](README.md) (Accessing Services)
- **Adding slaves** → [README.md](README.md) (Customization)

### Troubleshooting
- **Common issues** → [QUICKSTART.md](QUICKSTART.md) (Troubleshooting)
- **Detailed debugging** → [README.md](README.md) (Troubleshooting)
- **Security incidents** → [SECURITY.md](SECURITY.md) (Incident Response)

### Security
- **Key management** → [SECURITY.md](SECURITY.md) (Secure Key Management)
- **Best practices** → [SECURITY.md](SECURITY.md) (Security Best Practices)
- **Security checklist** → [SECURITY.md](SECURITY.md) (Security Checklist)
- **Incident response** → [SECURITY.md](SECURITY.md) (Incident Response)

## 🔑 Key Concepts

### What is This Infrastructure?

**Master Node** (1x t3.medium)
- Puppet Server: Automates configuration of slave nodes
- Nagios Server: Monitors health of all nodes
- Web Interface: Access monitoring at http://master-ip/nagios

**Slave Nodes** (2x t3.small)
- Puppet Agent: Auto-configured by master
- NRPE: Reports metrics to Nagios
- Worker Nodes: Run your applications

**Terraform**
- Infrastructure as Code
- Creates all AWS resources automatically
- Manages SSH keys, networking, security groups

**Monitoring**
- CPU Load, Memory Usage, Disk Space
- 5-minute check intervals
- Web dashboard in Nagios

## ⚡ Common Commands Reference

### Terraform
```powershell
terraform init          # Initialize
terraform plan          # Preview changes
terraform apply         # Deploy
terraform destroy       # Delete everything
terraform output        # Show outputs
```

### Puppet (on Master)
```bash
# List certificate requests
sudo /opt/puppetlabs/bin/puppetserver ca list

# Sign all certificates
sudo /opt/puppetlabs/bin/puppetserver ca sign --all

# Check Puppet status
sudo systemctl status puppetserver
```

### Puppet (on Slave)
```bash
# Run Puppet agent
sudo /opt/puppetlabs/bin/puppet agent --test

# Check agent status
sudo systemctl status puppet
```

### Nagios (on Master)
```bash
# Check Nagios status
sudo systemctl status nagios

# Verify configuration
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Restart Nagios
sudo systemctl restart nagios

# Test NRPE to slave
/usr/local/nagios/libexec/check_nrpe -H <slave_ip> -c check_load
```

### NRPE (on Slave)
```bash
# Check NRPE status
sudo systemctl status nagios-nrpe-server

# Test locally
/usr/lib/nagios/plugins/check_nrpe -H localhost -c check_load
```

## 🎓 Learning Path

### Beginner
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Deploy using `deploy.ps1`
3. Access Nagios web interface
4. Connect to instances via SSH

### Intermediate
1. Read [README.md](README.md) completely
2. Understand Puppet certificate signing
3. Customize monitoring thresholds
4. Add more slave nodes

### Advanced
1. Study [ARCHITECTURE.md](ARCHITECTURE.md)
2. Modify Puppet manifests
3. Add custom Nagios checks
4. Implement advanced security (HTTPS, SSM)
5. Integrate with CI/CD

## 💡 Tips & Best Practices

### Before Deployment
✅ Read [SECURITY.md](SECURITY.md) first
✅ Have AWS credentials configured
✅ Choose appropriate instance types
✅ Plan your monitoring needs

### After Deployment
✅ Secure your private key immediately
✅ Change default Nagios password
✅ Wait 5-10 minutes for services to start
✅ Verify monitoring is working
✅ Document your configuration

### For Production
✅ Use existing key pairs (not auto-generated)
✅ Restrict security groups to specific IPs
✅ Enable HTTPS for Nagios
✅ Set up automated backups
✅ Configure CloudWatch alarms
✅ Enable AWS GuardDuty
✅ Use AWS Secrets Manager for credentials

## 🆘 Getting Help

### Error: "Key pair not found"
→ [SECURITY.md](SECURITY.md) (Secure Key Management Options)

### Error: "Puppet agent can't connect"
→ [QUICKSTART.md](QUICKSTART.md) (Troubleshooting)

### Error: "Nagios not showing slaves"
→ [README.md](README.md) (Troubleshooting)

### Security Concerns
→ [SECURITY.md](SECURITY.md) (Incident Response)

### General Questions
→ [README.md](README.md) (Support section)

## 📊 Cost Optimization

- **Development**: Use t3.micro instances
- **Testing**: Current setup (~$60/month)
- **Production**: Scale as needed

Stop instances when not in use:
```powershell
# Stop all instances
aws ec2 stop-instances --instance-ids <instance-ids>

# Or destroy completely
terraform destroy
```

## 🔄 Update & Maintenance

### Update Infrastructure
1. Modify `terraform.tfvars` or `.tf` files
2. Run `terraform plan` to preview
3. Run `terraform apply` to update

### Update Puppet Configurations
1. SSH to master
2. Edit `/etc/puppetlabs/code/environments/production/manifests/site.pp`
3. Slaves will auto-update in 30 minutes (or run puppet agent manually)

### Update Nagios Checks
1. SSH to master
2. Edit `/usr/local/nagios/etc/objects/slaves.cfg`
3. Run: `sudo systemctl restart nagios`

## 🎯 Next Steps After Reading

1. ✅ Review [SECURITY.md](SECURITY.md) for critical security info
2. ✅ Run `deploy.ps1` to deploy
3. ✅ Access Nagios and verify monitoring
4. ✅ Test SSH access to all nodes
5. ✅ Customize for your needs
6. ✅ Set up backups and monitoring alerts

---

## 📞 Quick Reference

| What | Where | How |
|------|-------|-----|
| Deploy | [QUICKSTART.md](QUICKSTART.md) | `terraform apply` |
| Access Nagios | Browser | `http://<master_ip>/nagios` |
| SSH to Master | Terminal | `ssh -i key.pem ubuntu@<master_ip>` |
| Sign Puppet Cert | Master SSH | `sudo puppetserver ca sign --all` |
| Check Monitoring | Nagios Web | Services → All |
| Add Slaves | [README.md](README.md) | Edit `slave_count` in tfvars |
| Secure Keys | [SECURITY.md](SECURITY.md) | `icacls` commands |
| Destroy | Terminal | `terraform destroy` |

---

**Need something specific? Use the documentation links above! 🚀**
