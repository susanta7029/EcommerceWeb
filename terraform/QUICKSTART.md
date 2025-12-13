# 🚀 Quick Deployment Guide

## ⚡ Fast Track Deployment (5 minutes)

### Step 1: Prerequisites Check
```powershell
# Check Terraform
terraform version

# Check AWS CLI
aws --version

# Configure AWS credentials (if not already done)
aws configure
```

### Step 2: Deploy
```powershell
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (auto-creates SSH keys)
terraform apply -auto-approve
```

### Step 3: Access Your Infrastructure

After deployment (wait 5-10 minutes for services to install):

1. **Get the Nagios URL** from Terraform output
2. **Open browser**: `http://<master_ip>/nagios`
3. **Login**:
   - Username: `nagiosadmin`
   - Password: `nagiosadmin` (change immediately!)

### Step 4: Secure Your Environment

```powershell
# Secure the private key
icacls terraform\private-key.pem /inheritance:r
icacls terraform\private-key.pem /grant:r "$($env:USERNAME):(R)"

# Move to secure location
Move-Item terraform\private-key.pem ~\.ssh\infrastructure-key.pem
```

### Step 5: Connect via SSH

```powershell
# Connect to master
ssh -i ~\.ssh\infrastructure-key.pem ubuntu@<master_ip>

# Connect to slave
ssh -i ~\.ssh\infrastructure-key.pem ubuntu@<slave_ip>
```

---

## 🎯 What You Get

✅ **1 Master Node** running:
- Puppet Server (configuration management)
- Nagios Core (monitoring)

✅ **2 Slave Nodes** with:
- Puppet Agent (auto-configured)
- NRPE (monitored by Nagios)

✅ **Monitoring**:
- CPU Load
- Memory Usage
- Disk Space

✅ **All automated** through Terraform!

---

## 🔧 Common Tasks

### View Puppet Certificate Requests
```bash
# On master
sudo /opt/puppetlabs/bin/puppetserver ca list
```

### Sign Puppet Certificates
```bash
# Sign all
sudo /opt/puppetlabs/bin/puppetserver ca sign --all

# Sign specific
sudo /opt/puppetlabs/bin/puppetserver ca sign --certname slave-1
```

### Check Nagios Status
```bash
# On master
sudo systemctl status nagios
```

### Test NRPE from Master
```bash
# On master
/usr/local/nagios/libexec/check_nrpe -H <slave_ip> -c check_load
/usr/local/nagios/libexec/check_nrpe -H <slave_ip> -c check_mem
```

### Run Puppet Agent Manually
```bash
# On slave
sudo /opt/puppetlabs/bin/puppet agent --test
```

---

## 🛑 Cleanup (Destroy Everything)

```powershell
cd terraform
terraform destroy -auto-approve
```

---

## 📊 Monitoring Dashboard

Navigate to: **Services** → **All** in Nagios web interface

You'll see:
- slave-1: CPU Load, Memory Usage, Disk Usage
- slave-2: CPU Load, Memory Usage, Disk Usage

**Color coding:**
- 🟢 Green = OK
- 🟡 Yellow = Warning
- 🔴 Red = Critical

---

## 💰 Estimated Costs

**Approximate monthly costs (us-east-1):**
- 1 x t3.medium: ~$30/month
- 2 x t3.small: ~$30/month
- **Total: ~$60/month**

💡 **Tip**: Use `terraform destroy` when not needed to save costs!

---

## 🆘 Troubleshooting

### Puppet agents not connecting?
```bash
# On master - check if puppetserver is running
sudo systemctl status puppetserver

# On slave - check puppet agent
sudo systemctl status puppet
```

### Nagios not showing slaves?
```bash
# On master - verify configuration
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Restart Nagios
sudo systemctl restart nagios
```

### Can't SSH to instances?
1. Check security group allows SSH from your IP
2. Verify you're using correct private key
3. Check instance is running: `aws ec2 describe-instances`

### NRPE connection refused?
```bash
# On slave - check NRPE status
sudo systemctl status nagios-nrpe-server

# Check firewall
sudo ufw status
```

---

## 📚 Documentation

- **README.md** - Complete guide
- **SECURITY.md** - Security best practices ⚠️ READ THIS!
- **ARCHITECTURE.md** - Architecture details

---

## 🔐 Security Checklist

Before going to production:

- [ ] Change Nagios password
- [ ] Restrict SSH to your IP only
- [ ] Enable HTTPS for Nagios
- [ ] Move private key to secure location
- [ ] Enable AWS CloudTrail
- [ ] Set up backup strategy
- [ ] Configure AWS GuardDuty
- [ ] Review security groups
- [ ] Enable MFA on AWS account
- [ ] Document access procedures

---

## 📞 Need Help?

1. Check the troubleshooting section above
2. Review logs:
   - Terraform: Check console output
   - Puppet: `/var/log/puppetlabs/`
   - Nagios: `/usr/local/nagios/var/nagios.log`
   - System: `sudo journalctl -xe`

---

**Happy Monitoring! 🎉**
