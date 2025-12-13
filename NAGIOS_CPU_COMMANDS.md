# Nagios Commands for CPU Monitoring on EC2

## Your Infrastructure Details

**Master Node (Nagios Server):**
- Public IP: `34.205.2.4`
- Private IP: `10.0.1.105`

**Slave Nodes (Worker Nodes):**
- Slave 1: `44.201.53.61` (Private: `10.0.1.162`)
- Slave 2: `44.200.209.217` (Private: `10.0.1.107`)

---

## Connect to Master Node (Nagios Server)

```powershell
ssh -i private-key.pem ubuntu@34.205.2.4
```

---

## Nagios Commands on Master Node

### 1. Check Nagios Status

```bash
sudo systemctl status nagios
```

### 2. Check CPU Load on Slave Nodes (via NRPE)

**Check Slave 1 CPU:**
```bash
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_load
```

**Check Slave 2 CPU:**
```bash
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_load
```

### 3. Check CPU Usage (Custom Script)

**Check Slave 1:**
```bash
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_cpu
```

**Check Slave 2:**
```bash
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_cpu
```

### 4. Check All Monitoring Metrics

**Slave 1 - All Checks:**
```bash
# CPU Load
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_load

# CPU Usage
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_cpu

# Memory
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_mem

# Disk
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_disk
```

**Slave 2 - All Checks:**
```bash
# CPU Load
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_load

# CPU Usage
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_cpu

# Memory
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_mem

# Disk
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_disk
```

### 5. View Nagios Logs

```bash
# Main Nagios log
sudo tail -f /usr/local/nagios/var/nagios.log

# Check warnings/errors
sudo grep -i "warning\|error\|critical" /usr/local/nagios/var/nagios.log | tail -20
```

### 6. Verify Nagios Configuration

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

### 7. Restart Nagios

```bash
sudo systemctl restart nagios
```

---

## Commands on Slave Nodes

### Connect to Slave Nodes

**Slave 1:**
```powershell
ssh -i private-key.pem ubuntu@44.201.53.61
```

**Slave 2:**
```powershell
ssh -i private-key.pem ubuntu@44.200.209.217
```

### Check NRPE Status on Slave

```bash
sudo systemctl status nagios-nrpe-server
```

### Test CPU Checks Locally on Slave

```bash
# Test CPU load locally
/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20

# Test CPU usage
/usr/local/bin/check_cpu.sh

# Test memory
/usr/local/bin/check_mem.sh

# Test disk
/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
```

### View CPU Information

```bash
# Current CPU usage
top -bn1 | grep "Cpu(s)"

# Load average
uptime

# Detailed CPU info
mpstat

# CPU usage by process
ps aux --sort=-%cpu | head -10
```

### Check NRPE Configuration

```bash
sudo cat /etc/nagios/nrpe.cfg | grep -E "allowed_hosts|command"
```

### View NRPE Logs

```bash
sudo journalctl -u nagios-nrpe-server -f
```

---

## Web Interface Commands

### Access Nagios Web Dashboard

Open in browser:
```
http://34.205.2.4/nagios
```

**Login:**
- Username: `nagiosadmin`
- Password: `nagiosadmin` (CHANGE THIS!)

### Navigate to CPU Monitoring

1. Click **Services** → **All**
2. Look for:
   - `slave-1` → `CPU Load`
   - `slave-2` → `CPU Load`

---

## Troubleshooting Commands

### If NRPE Connection Fails

**On Master:**
```bash
# Test network connectivity
ping 10.0.1.162
ping 10.0.1.107

# Test NRPE port (5666)
telnet 10.0.1.162 5666
telnet 10.0.1.107 5666
```

**On Slave:**
```bash
# Check if NRPE is listening
sudo netstat -tulpn | grep 5666

# Check firewall
sudo ufw status

# Restart NRPE
sudo systemctl restart nagios-nrpe-server
```

### If CPU Check Returns Unknown

**On Slave:**
```bash
# Check if monitoring scripts exist
ls -la /usr/local/bin/check_*.sh

# Make scripts executable
sudo chmod +x /usr/local/bin/check_cpu.sh
sudo chmod +x /usr/local/bin/check_mem.sh

# Test scripts directly
/usr/local/bin/check_cpu.sh
```

---

## Quick Reference

### Master Node Commands
```bash
# SSH to master
ssh -i private-key.pem ubuntu@34.205.2.4

# Check slave 1 CPU
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.162 -c check_load

# Check slave 2 CPU
/usr/local/nagios/libexec/check_nrpe -H 10.0.1.107 -c check_load

# View Nagios status
sudo systemctl status nagios

# Restart Nagios
sudo systemctl restart nagios
```

### Slave Node Commands
```bash
# SSH to slave 1
ssh -i private-key.pem ubuntu@44.201.53.61

# SSH to slave 2
ssh -i private-key.pem ubuntu@44.200.209.217

# Check NRPE status
sudo systemctl status nagios-nrpe-server

# Test CPU check locally
/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20

# View current CPU
top -bn1 | grep Cpu
```

---

## Expected Output Examples

### Normal CPU Load (OK):
```
OK - load average: 0.15, 0.20, 0.18 | load1=0.150;15.000;30.000;0; load5=0.200;10.000;25.000;0; load15=0.180;5.000;20.000;0;
```

### Warning CPU Load:
```
WARNING - load average: 16.50, 12.20, 8.45 | load1=16.500;15.000;30.000;0; load5=12.200;10.000;25.000;0; load15=8.450;5.000;20.000;0;
```

### Critical CPU Load:
```
CRITICAL - load average: 35.20, 28.15, 22.80 | load1=35.200;15.000;30.000;0; load5=28.150;10.000;25.000;0; load15=22.800;5.000;20.000;0;
```

---

## Complete Setup Checklist

Before checking CPU, ensure:

1. ✅ Upload Nagios slaves configuration:
   ```powershell
   scp -i private-key.pem generated/slaves.cfg ubuntu@34.205.2.4:/tmp/
   ```

2. ✅ Apply configuration on master:
   ```bash
   ssh -i private-key.pem ubuntu@34.205.2.4
   sudo mv /tmp/slaves.cfg /usr/local/nagios/etc/objects/slaves.cfg
   sudo systemctl restart nagios
   ```

3. ✅ Wait 5-10 minutes for all services to initialize

4. ✅ Check Nagios web interface: http://34.205.2.4/nagios

---

**Now you can monitor CPU on all your EC2 worker nodes!** 🎯
