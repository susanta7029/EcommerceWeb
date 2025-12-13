#!/bin/bash
# Master Node Initialization Script
# Installs Puppet Master and Nagios Server

set -e

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y wget curl gnupg2 software-properties-common

echo "===== Installing Puppet Server ====="

# Install Puppet Server
wget https://apt.puppet.com/puppet7-release-jammy.deb
sudo dpkg -i puppet7-release-jammy.deb
sudo apt-get update
sudo apt-get install -y puppetserver

# Configure Puppet Server
sudo sed -i 's/Xms2g/Xms512m/g' /etc/default/puppetserver
sudo sed -i 's/Xmx2g/Xmx512m/g' /etc/default/puppetserver

# Start and enable Puppet Server
sudo systemctl start puppetserver
sudo systemctl enable puppetserver

# Configure Puppet
echo "*.$(hostname -d)" | sudo tee /etc/puppetlabs/puppet/autosign.conf

echo "===== Installing Nagios ====="

# Install dependencies for Nagios
sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php \
    libgd-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext

# Download and install Nagios Core
cd /tmp
NAGIOS_VERSION="4.4.14"
wget https://github.com/NagiosEnterprises/nagioscore/archive/nagios-${NAGIOS_VERSION}.tar.gz
tar xzf nagios-${NAGIOS_VERSION}.tar.gz
cd nagioscore-nagios-${NAGIOS_VERSION}

sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all
sudo make install-groups-users
sudo usermod -a -G nagios www-data
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Enable Apache modules
sudo a2enmod rewrite
sudo a2enmod cgi

# Create Nagios admin user
echo "nagiosadmin:$(openssl passwd -apr1 'nagiosadmin')" | sudo tee /usr/local/nagios/etc/htpasswd.users

# Install Nagios Plugins
cd /tmp
PLUGIN_VERSION="2.4.6"
wget https://github.com/nagios-plugins/nagios-plugins/archive/release-${PLUGIN_VERSION}.tar.gz
tar xzf release-${PLUGIN_VERSION}.tar.gz
cd nagios-plugins-release-${PLUGIN_VERSION}
sudo ./tools/setup
sudo ./configure
sudo make
sudo make install

# Note: Slave configuration will be added by Terraform after all instances are created
# This placeholder file will be replaced
sudo tee /usr/local/nagios/etc/objects/slaves.cfg > /dev/null <<'EOF'
# Slave Node Definitions
# This file will be automatically configured by Terraform
EOF

# Add slaves.cfg to nagios.cfg
sudo bash -c 'echo "cfg_file=/usr/local/nagios/etc/objects/slaves.cfg" >> /usr/local/nagios/etc/nagios.cfg'

# Define check_nrpe command
sudo tee -a /usr/local/nagios/etc/objects/commands.cfg > /dev/null <<'EOF'

# NRPE Command Definition
define command {
    command_name    check_nrpe
    command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
EOF

# Install NRPE plugin
cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.1.0/nrpe-4.1.0.tar.gz
tar xzf nrpe-4.1.0.tar.gz
cd nrpe-4.1.0
sudo ./configure
sudo make check_nrpe
sudo make install-plugin

# Start and enable services
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl start nagios
sudo systemctl enable nagios

echo "===== Creating Puppet Manifests ====="

# Create Puppet manifest for slave configuration
sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests
sudo tee /etc/puppetlabs/code/environments/production/manifests/site.pp > /dev/null <<'PUPPET_EOF'
node default {
  # Ensure NRPE is installed and configured
  package { 'nagios-nrpe-server':
    ensure => installed,
  }

  package { 'nagios-plugins':
    ensure => installed,
  }

  # Configure NRPE
  file { '/etc/nagios/nrpe.cfg':
    ensure  => file,
    content => template('nrpe/nrpe.cfg.erb'),
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  service { 'nagios-nrpe-server':
    ensure  => running,
    enable  => true,
    require => Package['nagios-nrpe-server'],
  }

  # Install monitoring scripts
  file { '/usr/local/bin/check_mem.sh':
    ensure => file,
    mode   => '0755',
    content => @("MEMSCRIPT"/L)
      #!/bin/bash
      FREE_MEM=\$(free -m | awk 'NR==2{printf "%.2f", \$3*100/\$2}')
      echo "Memory usage: \$FREE_MEM%"
      if (( \$(echo "\$FREE_MEM > 90" | bc -l) )); then
        exit 2
      elif (( \$(echo "\$FREE_MEM > 80" | bc -l) )); then
        exit 1
      else
        exit 0
      fi
      | MEMSCRIPT
  }
}
PUPPET_EOF

# Create NRPE template directory
sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/nrpe/templates

# Create NRPE configuration template
sudo tee /etc/puppetlabs/code/environments/production/modules/nrpe/templates/nrpe.cfg.erb > /dev/null <<'NRPE_EOF'
log_facility=daemon
pid_file=/var/run/nagios/nrpe.pid
server_port=5666
nrpe_user=nagios
nrpe_group=nagios
allowed_hosts=127.0.0.1,<%= @master_ip %>
dont_blame_nrpe=0
allow_bash_command_substitution=0
debug=0
command_timeout=60
connection_timeout=300

# Command definitions
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_mem]=/usr/local/bin/check_mem.sh
NRPE_EOF

echo "===== Installation Complete ====="
echo "Nagios URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/nagios"
echo "Nagios Username: nagiosadmin"
echo "Nagios Password: nagiosadmin"
echo "Puppet Server is running on port 8140"
