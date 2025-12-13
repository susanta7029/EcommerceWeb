#!/bin/bash
# Slave Node Initialization Script
# Installs Puppet Agent and NRPE for Nagios monitoring

set -e

# Update system
sudo apt-get update
sudo apt-get upgrade -y

echo "===== Installing Puppet Agent ====="

# Install Puppet Agent
wget https://apt.puppet.com/puppet7-release-jammy.deb
sudo dpkg -i puppet7-release-jammy.deb
sudo apt-get update
sudo apt-get install -y puppet-agent

# Configure Puppet Agent
sudo tee /etc/puppetlabs/puppet/puppet.conf > /dev/null <<EOF
[main]
certname = slave-${slave_index}
server = ${master_ip}
environment = production
runinterval = 30m

[agent]
report = true
EOF

# Start and enable Puppet Agent
sudo systemctl start puppet
sudo systemctl enable puppet

# Run Puppet agent to configure NRPE
sudo /opt/puppetlabs/bin/puppet agent --test --waitforcert 60 || true

echo "===== Installing NRPE and Nagios Plugins ====="

# Install NRPE and plugins
sudo apt-get install -y nagios-nrpe-server nagios-plugins

# Configure NRPE
sudo tee /etc/nagios/nrpe.cfg > /dev/null <<EOF
log_facility=daemon
pid_file=/var/run/nagios/nrpe.pid
server_port=5666
nrpe_user=nagios
nrpe_group=nagios
allowed_hosts=127.0.0.1,${master_ip}
dont_blame_nrpe=0
allow_bash_command_substitution=0
debug=0
command_timeout=60
connection_timeout=300

# Command definitions for CPU, Memory, and Disk monitoring
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_mem]=/usr/local/bin/check_mem.sh
command[check_cpu]=/usr/local/bin/check_cpu.sh
EOF

# Create memory check script
sudo tee /usr/local/bin/check_mem.sh > /dev/null <<'EOF'
#!/bin/bash
# Memory usage check script

USED_MEM=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
USED_MEM_MB=$(free -m | awk 'NR==2{print $3}')

echo "Memory: $${USED_MEM_MB}MB used of $${TOTAL_MEM}MB ($${USED_MEM}%)"

if (( $(echo "$USED_MEM > 90" | bc -l) )); then
    exit 2  # Critical
elif (( $(echo "$USED_MEM > 80" | bc -l) )); then
    exit 1  # Warning
else
    exit 0  # OK
fi
EOF

# Create CPU check script
sudo tee /usr/local/bin/check_cpu.sh > /dev/null <<'EOF'
#!/bin/bash
# CPU usage check script

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

echo "CPU Usage: $${CPU_USAGE}%"

if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
    exit 2  # Critical
elif (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    exit 1  # Warning
else
    exit 0  # OK
fi
EOF

# Make scripts executable
sudo chmod +x /usr/local/bin/check_mem.sh
sudo chmod +x /usr/local/bin/check_cpu.sh

# Restart NRPE service
sudo systemctl restart nagios-nrpe-server
sudo systemctl enable nagios-nrpe-server

echo "===== Installing Additional Monitoring Tools ====="

# Install sysstat for CPU monitoring
sudo apt-get install -y sysstat bc

# Enable sysstat
sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
sudo systemctl restart sysstat

echo "===== Slave Node ${slave_index} Configuration Complete ====="
echo "This node is now managed by Puppet Master at ${master_ip}"
echo "NRPE is listening on port 5666 for Nagios monitoring"
