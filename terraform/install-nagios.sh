#!/bin/bash
set -e

echo "Installing Nagios Core..."

# Install dependencies
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq autoconf gcc libc6 make wget unzip apache2 apache2-utils php libapache2-mod-php php-gd libgd-dev openssl libssl-dev

# Download and install Nagios Core
cd /tmp
NAGIOS_VERSION="4.4.14"
wget -q https://github.com/NagiosEnterprises/nagioscore/archive/nagios-${NAGIOS_VERSION}.tar.gz
tar xzf nagios-${NAGIOS_VERSION}.tar.gz
cd nagioscore-nagios-${NAGIOS_VERSION}

./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
sudo make install-groups-users
sudo usermod -a -G nagios www-data
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Create Nagios admin user
echo "nagiosadmin:admin123" | sudo chpasswd -c SHA512

# Enable Apache modules
sudo a2enmod rewrite
sudo a2enmod cgi

# Download and install Nagios Plugins
cd /tmp
PLUGIN_VERSION="2.4.6"
wget -q https://github.com/nagios-plugins/nagios-plugins/archive/release-${PLUGIN_VERSION}.tar.gz
tar xzf release-${PLUGIN_VERSION}.tar.gz
cd nagios-plugins-release-${PLUGIN_VERSION}

./tools/setup
./configure
make
sudo make install

# Install NRPE
cd /tmp
wget -q https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.1.0/nrpe-4.1.0.tar.gz
tar xzf nrpe-4.1.0.tar.gz
cd nrpe-4.1.0
./configure
make check_nrpe
sudo make install-plugin

# Set permissions
sudo chown -R nagios:nagios /usr/local/nagios

# Add slaves configuration
if [ -f /tmp/slaves.cfg ]; then
    sudo mv /tmp/slaves.cfg /usr/local/nagios/etc/objects/
    echo "cfg_file=/usr/local/nagios/etc/objects/slaves.cfg" | sudo tee -a /usr/local/nagios/etc/nagios.cfg
fi

# Restart services
sudo systemctl restart apache2
sudo systemctl enable nagios
sudo systemctl restart nagios

echo "Nagios installation complete!"
echo "Access Nagios at: http://34.205.2.4/nagios"
echo "Username: nagiosadmin"
echo "Password: admin123"
